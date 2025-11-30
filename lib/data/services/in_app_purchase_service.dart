import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import '../models/premium_tier.dart';
import 'subscription_service.dart';

/// 인앱 구매 서비스
///
/// iOS App Store와 Android Play Store의 인앱 구매를 처리합니다.
/// 구독 상품 조회, 구매, 복원, 영수증 검증 등을 담당합니다.
class InAppPurchaseService {
  final InAppPurchase _inAppPurchase;
  final SubscriptionService _subscriptionService;

  // 구독 상품 ID (App Store Connect와 Play Console에서 설정)
  static const String monthlyProductId = 'mathlab_premium_monthly';
  static const String yearlyProductId = 'mathlab_premium_yearly';
  static const String lifetimeProductId = 'mathlab_premium_lifetime';

  // 구매 상태 스트림
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  // 사용 가능한 상품 목록
  List<ProductDetails> _products = [];

  // 구매 진행 중 플래그
  bool _purchaseInProgress = false;

  // 구매 완료 콜백
  Function(bool success, String? error)? _onPurchaseComplete;

  InAppPurchaseService({
    InAppPurchase? inAppPurchase,
    SubscriptionService? subscriptionService,
  })  : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance,
        _subscriptionService = subscriptionService ?? SubscriptionService();

  // ========================================
  // 초기화 (INITIALIZATION)
  // ========================================

  /// 인앱 구매 시스템 초기화
  ///
  /// 앱 시작 시 한 번 호출해야 합니다.
  /// 구매 상태 리스너를 설정하고, 미완료 거래를 처리합니다.
  Future<bool> initialize() async {
    // 인앱 구매 사용 가능 여부 확인
    final available = await _inAppPurchase.isAvailable();
    if (!available) {
      print('[IAP] 인앱 구매를 사용할 수 없습니다');
      return false;
    }

    // iOS 전용 설정
    if (Platform.isIOS) {
      final iosPlatform =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatform.setDelegate(
        ExamplePaymentQueueDelegate(),
      );
    }

    // 구매 스트림 리스닝 시작
    _purchaseSubscription =
        _inAppPurchase.purchaseStream.listen(_onPurchaseUpdated);

    // 상품 정보 로드
    await loadProducts();

    // 미완료 거래 처리
    await _restorePendingPurchases();

    print('[IAP] 초기화 완료');
    return true;
  }

  /// 리소스 정리
  void dispose() {
    _purchaseSubscription?.cancel();
  }

  // ========================================
  // 상품 조회 (PRODUCTS)
  // ========================================

  /// 구독 상품 정보 로드
  ///
  /// App Store Connect / Play Console에 등록된 상품 정보를 가져옵니다.
  Future<bool> loadProducts() async {
    const productIds = {
      monthlyProductId,
      yearlyProductId,
      lifetimeProductId,
    };

    try {
      final response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        print('[IAP] 상품 조회 오류: ${response.error}');
        return false;
      }

      if (response.productDetails.isEmpty) {
        print('[IAP] 등록된 상품이 없습니다');
        return false;
      }

      _products = response.productDetails;
      print('[IAP] ${_products.length}개 상품 로드 완료');

      // 상품 정보 출력
      for (final product in _products) {
        print(
            '[IAP] ${product.id}: ${product.price} (${product.currencyCode})');
      }

      return true;
    } catch (e) {
      print('[IAP] 상품 로드 오류: $e');
      return false;
    }
  }

  /// 사용 가능한 상품 목록 조회
  List<ProductDetails> get availableProducts => _products;

  /// 특정 등급의 상품 조회
  ProductDetails? getProductForTier(PremiumTier tier) {
    String productId;

    switch (tier) {
      case PremiumTier.monthly:
        productId = monthlyProductId;
        break;
      case PremiumTier.yearly:
        productId = yearlyProductId;
        break;
      case PremiumTier.lifetime:
        productId = lifetimeProductId;
        break;
      default:
        return null;
    }

    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // ========================================
  // 구매 (PURCHASE)
  // ========================================

  /// 구독 구매 시작
  ///
  /// 선택한 등급의 구독을 구매합니다.
  /// onComplete 콜백으로 결과를 받습니다.
  Future<void> purchaseSubscription({
    required String userId,
    required PremiumTier tier,
    required Function(bool success, String? error) onComplete,
  }) async {
    if (_purchaseInProgress) {
      onComplete(false, '이미 구매가 진행 중입니다');
      return;
    }

    final product = getProductForTier(tier);
    if (product == null) {
      onComplete(false, '상품을 찾을 수 없습니다');
      return;
    }

    _purchaseInProgress = true;
    _onPurchaseComplete = onComplete;

    try {
      // 구매 파라미터 생성
      final purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: userId, // 사용자 ID (선택 사항)
      );

      // 구매 요청
      final success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!success) {
        _purchaseInProgress = false;
        onComplete(false, '구매를 시작할 수 없습니다');
      }
      // 성공 시 _onPurchaseUpdated에서 처리됨
    } catch (e) {
      _purchaseInProgress = false;
      onComplete(false, '구매 오류: $e');
    }
  }

  /// 구매 상태 업데이트 처리
  ///
  /// 구매 스트림에서 호출되는 콜백입니다.
  Future<void> _onPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      print('[IAP] 구매 상태: ${purchaseDetails.status}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          // 구매 대기 중 (사용자가 결제 프로세스 진행 중)
          print('[IAP] 결제 대기 중...');
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // 구매 완료 또는 복원 완료
          await _handlePurchaseSuccess(purchaseDetails);
          break;

        case PurchaseStatus.error:
          // 구매 오류
          _handlePurchaseError(purchaseDetails);
          break;

        case PurchaseStatus.canceled:
          // 사용자가 구매 취소
          _handlePurchaseCanceled();
          break;
      }

      // 완료된 거래 처리 (필수!)
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// 구매 성공 처리
  Future<void> _handlePurchaseSuccess(PurchaseDetails purchaseDetails) async {
    print('[IAP] 구매 성공: ${purchaseDetails.productID}');

    try {
      // 영수증 검증 (서버 사이드 검증 권장)
      final isValid = await _verifyPurchase(purchaseDetails);
      if (!isValid) {
        print('[IAP] 영수증 검증 실패');
        _purchaseInProgress = false;
        _onPurchaseComplete?.call(false, '영수증 검증 실패');
        return;
      }

      // 구독 등급 결정
      final tier = _getTierFromProductId(purchaseDetails.productID);
      if (tier == null) {
        print('[IAP] 알 수 없는 상품: ${purchaseDetails.productID}');
        _purchaseInProgress = false;
        _onPurchaseComplete?.call(false, '알 수 없는 상품');
        return;
      }

      // userId는 applicationUserName에서 가져옴
      // 실제로는 현재 로그인한 사용자 ID를 사용해야 함
      final userId = purchaseDetails.purchaseID ?? 'unknown_user';

      // Firestore에 구독 생성
      await _subscriptionService.startNewSubscription(
        userId: userId,
        tier: tier,
        transactionId: purchaseDetails.purchaseID ?? '',
        platform: Platform.isIOS ? 'ios' : 'android',
      );

      print('[IAP] Firestore 구독 생성 완료');

      _purchaseInProgress = false;
      _onPurchaseComplete?.call(true, null);
    } catch (e) {
      print('[IAP] 구매 처리 오류: $e');
      _purchaseInProgress = false;
      _onPurchaseComplete?.call(false, '구매 처리 오류: $e');
    }
  }

  /// 구매 오류 처리
  void _handlePurchaseError(PurchaseDetails purchaseDetails) {
    print('[IAP] 구매 오류: ${purchaseDetails.error}');

    _purchaseInProgress = false;
    _onPurchaseComplete?.call(
      false,
      purchaseDetails.error?.message ?? '구매 실패',
    );
  }

  /// 구매 취소 처리
  void _handlePurchaseCanceled() {
    print('[IAP] 사용자가 구매 취소');

    _purchaseInProgress = false;
    _onPurchaseComplete?.call(false, '구매가 취소되었습니다');
  }

  // ========================================
  // 구매 복원 (RESTORE)
  // ========================================

  /// 이전 구매 복원
  ///
  /// 기기 변경 시 또는 앱 재설치 후 이전 구매를 복원합니다.
  /// iOS에서는 필수 기능입니다.
  Future<bool> restorePurchases(String userId) async {
    try {
      print('[IAP] 구매 복원 시작...');

      await _inAppPurchase.restorePurchases();

      // 복원된 구매는 _onPurchaseUpdated에서 처리됨
      print('[IAP] 구매 복원 요청 완료');

      return true;
    } catch (e) {
      print('[IAP] 구매 복원 오류: $e');
      return false;
    }
  }

  /// 미완료 거래 처리
  ///
  /// 앱이 종료되기 전에 완료되지 않은 거래를 처리합니다.
  Future<void> _restorePendingPurchases() async {
    try {
      // QueryPurchaseDetails는 미완료 거래만 반환
      // iOS: 완료되지 않은 거래
      // Android: 소비되지 않은 구매
      await _inAppPurchase.restorePurchases();
      print('[IAP] 미완료 거래 처리 완료');
    } catch (e) {
      print('[IAP] 미완료 거래 처리 오류: $e');
    }
  }

  // ========================================
  // 영수증 검증 (VERIFICATION)
  // ========================================

  /// 영수증 검증
  ///
  /// **중요**: 실제 프로덕션에서는 반드시 서버에서 검증해야 합니다!
  /// 클라이언트 검증은 쉽게 우회될 수 있습니다.
  ///
  /// 서버 검증 플로우:
  /// 1. 클라이언트 → 서버: transactionId, receipt 전송
  /// 2. 서버 → Apple/Google: 영수증 검증 요청
  /// 3. Apple/Google → 서버: 검증 결과 응답
  /// 4. 서버 → Firestore: 구독 정보 저장
  /// 5. 서버 → 클라이언트: 성공/실패 응답
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // TODO: 서버 사이드 검증 구현
    // 현재는 간단한 로컬 검증만 수행

    // iOS 검증
    if (Platform.isIOS) {
      final iosPurchase =
          purchaseDetails as AppStorePurchaseDetails;
      // iOS 영수증이 있는지 확인
      if (iosPurchase.skPaymentTransaction.transactionIdentifier == null) {
        return false;
      }

      // TODO: 서버로 영수증 전송 및 검증
      // final receipt = iosPurchase.verificationData.serverVerificationData;
      // await _sendToServerForVerification(receipt);

      return true;
    }

    // Android 검증
    if (Platform.isAndroid) {
      final androidPurchase =
          purchaseDetails as GooglePlayPurchaseDetails;

      // TODO: 서버로 영수증 전송 및 검증
      // final purchaseToken = androidPurchase.verificationData.serverVerificationData;
      // await _sendToServerForVerification(purchaseToken);

      return true;
    }

    return false;
  }

  // ========================================
  // 유틸리티 (UTILITIES)
  // ========================================

  /// 상품 ID에서 PremiumTier 추출
  PremiumTier? _getTierFromProductId(String productId) {
    switch (productId) {
      case monthlyProductId:
        return PremiumTier.monthly;
      case yearlyProductId:
        return PremiumTier.yearly;
      case lifetimeProductId:
        return PremiumTier.lifetime;
      default:
        return null;
    }
  }

  /// 현재 구매 진행 중 여부
  bool get isPurchaseInProgress => _purchaseInProgress;

  /// 상품이 로드되었는지 확인
  bool get hasProducts => _products.isNotEmpty;
}

/// iOS Payment Queue Delegate
///
/// iOS에서 구매 트랜잭션을 처리하는 델리게이트입니다.
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}

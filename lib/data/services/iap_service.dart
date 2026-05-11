// 💳 In-App Purchase Service
//
// Google Play / App Store 결제 처리를 담당하는 서비스.
// in_app_purchase 패키지를 사용하여 실제 스토어 결제 흐름을 구현합니다.
//
// ⚠️ 영수증 위·변조 방지:
//   IapReceiptVerifier 구현체를 주입하면 _verifyAndDeliverProduct 가
//   서버 검증 결과를 기다린 뒤 프리미엄을 부여합니다.
//   verifier 가 null 이면 클라이언트 영수증을 그대로 신뢰하며 경고 로그를
//   남기므로, 프로덕션 출시 전에 반드시 구현체를 주입해야 합니다.

import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/utils/app_logger.dart';
import '../models/subscription/premium_tier.dart';

/// IAP 구매 결과 콜백 타입
typedef IapPurchaseCallback = void Function(
    bool success, String? productId, String? error);

/// 서버 영수증 검증 인터페이스.
///
/// 백엔드 endpoint 가 준비되면 본 인터페이스를 구현해 [IapService] 에 주입.
/// 구현체는 Apple/Google receipt 를 백엔드로 전송하고 검증 결과 boolean 을 반환.
/// 네트워크/서버 장애 등 검증 자체가 불가능한 상황은 예외를 던져
/// 호출자가 사용자에게 재시도 안내를 할 수 있게 한다.
abstract class IapReceiptVerifier {
  /// purchase.verificationData.serverVerificationData 를 서버로 전송.
  /// 반환값이 true 일 때만 IapService 가 프리미엄 활성화 콜백을 발화.
  Future<bool> verify({
    required String productId,
    required String source, // 'app_store' | 'google_play'
    required String verificationData,
    String? transactionId,
  });
}

/// In-App Purchase 서비스
///
/// Google Play / App Store의 구독 상품을 로드하고,
/// 구매/복원 처리를 수행합니다.
class IapService {
  static const String monthlyProductId = 'mathlab_premium_monthly';
  static const String yearlyProductId = 'mathlab_premium_yearly';

  static final Set<String> _productIds = {monthlyProductId, yearlyProductId};

  IapService({this.receiptVerifier});

  /// 서버 영수증 검증기 — null 이면 클라이언트 영수증을 그대로 신뢰 (dev 전용).
  final IapReceiptVerifier? receiptVerifier;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// 외부에서 구매 결과를 받기 위한 콜백
  IapPurchaseCallback? onPurchaseResult;

  /// IAP 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isAvailable = await _iap.isAvailable();
      if (!_isAvailable) {
        AppLogger.warning('IAP not available on this device', tag: 'IAP');
        _isInitialized = true;
        return;
      }

      // 구매 스트림 리스닝
      _subscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onError: (error) {
          AppLogger.error('IAP stream error', tag: 'IAP', error: error);
        },
      );

      // 상품 정보 로드
      await loadProducts();

      _isInitialized = true;
      AppLogger.info('IAP initialized successfully', tag: 'IAP');
    } catch (e, st) {
      AppLogger.error('IAP initialization failed',
          tag: 'IAP', error: e, stackTrace: st);
      _isInitialized = true; // 실패해도 초기화 완료 처리 (재시도 방지)
    }
  }

  /// 상품 정보 로드
  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    try {
      final response = await _iap.queryProductDetails(_productIds);

      if (response.error != null) {
        AppLogger.error(
          'Failed to load products: ${response.error?.message}',
          tag: 'IAP',
        );
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        AppLogger.warning(
          'Products not found: ${response.notFoundIDs.join(", ")}',
          tag: 'IAP',
        );
      }

      _products = response.productDetails;
      AppLogger.info('Loaded ${_products.length} products', tag: 'IAP');
    } catch (e, st) {
      AppLogger.error('Failed to load products',
          tag: 'IAP', error: e, stackTrace: st);
    }
  }

  /// PremiumTier에 해당하는 ProductDetails 가져오기
  ProductDetails? getProductForTier(PremiumTier tier) {
    final targetId = tier.productId;
    if (targetId.isEmpty) return null;

    try {
      return _products.firstWhere((p) => p.id == targetId);
    } catch (_) {
      return null;
    }
  }

  /// 구매 시작
  ///
  /// [product] 구매할 상품 정보
  /// Returns true if purchase flow was initiated successfully
  Future<bool> purchaseProduct(ProductDetails product) async {
    if (!_isAvailable) {
      AppLogger.warning('IAP not available, cannot purchase', tag: 'IAP');
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: product);
    try {
      // 구독 상품이므로 buyNonConsumable 사용
      // (auto-renewable subscription은 non-consumable로 처리)
      final result = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      AppLogger.info(
        'Purchase initiated for ${product.id}: $result',
        tag: 'IAP',
      );
      return result;
    } catch (e, st) {
      AppLogger.error('Purchase failed for ${product.id}',
          tag: 'IAP', error: e, stackTrace: st);
      return false;
    }
  }

  /// PremiumTier로 직접 구매 시작
  ///
  /// 스토어 상품이 로드되지 않은 경우 false 반환
  Future<bool> purchaseTier(PremiumTier tier) async {
    final product = getProductForTier(tier);
    if (product == null) {
      AppLogger.warning(
        'No product found for tier: ${tier.name}',
        tag: 'IAP',
      );
      return false;
    }
    return purchaseProduct(product);
  }

  /// 구매 복원
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      AppLogger.warning('IAP not available, cannot restore', tag: 'IAP');
      return;
    }

    try {
      await _iap.restorePurchases();
      AppLogger.info('Restore purchases initiated', tag: 'IAP');
    } catch (e, st) {
      AppLogger.error('Restore purchases failed',
          tag: 'IAP', error: e, stackTrace: st);
    }
  }

  /// 구매 업데이트 처리 (스트림 콜백)
  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      AppLogger.info(
        'Purchase update: ${purchase.productID} -> ${purchase.status}',
        tag: 'IAP',
      );

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _verifyAndDeliverProduct(purchase);
          break;
        case PurchaseStatus.error:
          AppLogger.error(
            'Purchase error for ${purchase.productID}: ${purchase.error?.message}',
            tag: 'IAP',
          );
          onPurchaseResult?.call(false, purchase.productID,
              purchase.error?.message ?? 'Purchase failed');
          break;
        case PurchaseStatus.pending:
          AppLogger.info(
              'Purchase pending: ${purchase.productID}', tag: 'IAP');
          break;
        case PurchaseStatus.canceled:
          AppLogger.info(
              'Purchase canceled: ${purchase.productID}', tag: 'IAP');
          onPurchaseResult?.call(false, purchase.productID, 'Canceled');
          break;
      }

      // 처리 완료 표시 (필수: 이를 하지 않으면 구매가 계속 pending 상태)
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  /// 구매 검증 및 제품 전달.
  ///
  /// [receiptVerifier] 가 주입돼 있으면 서버 검증 결과에 따라 분기하고,
  /// 없으면 클라이언트 영수증을 그대로 신뢰한다 (dev 전용 — 프로덕션 금지).
  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchase) async {
    final verifier = receiptVerifier;

    if (verifier == null) {
      AppLogger.warning(
        'Server receipt verification not configured — trusting client receipt. '
        'Inject IapReceiptVerifier before production release.',
        tag: 'IAP',
        data: {'productId': purchase.productID},
      );
      onPurchaseResult?.call(true, purchase.productID, null);
      return;
    }

    try {
      final ok = await verifier.verify(
        productId: purchase.productID,
        source: purchase.verificationData.source,
        verificationData: purchase.verificationData.serverVerificationData,
        transactionId: purchase.purchaseID,
      );

      if (ok) {
        AppLogger.info(
          'Purchase verified by server',
          tag: 'IAP',
          data: {
            'productId': purchase.productID,
            'source': purchase.verificationData.source,
            'transactionDate': purchase.transactionDate,
          },
        );
        onPurchaseResult?.call(true, purchase.productID, null);
      } else {
        AppLogger.warning(
          'Server rejected receipt — premium NOT granted',
          tag: 'IAP',
          data: {
            'productId': purchase.productID,
            'transactionId': purchase.purchaseID,
          },
        );
        onPurchaseResult?.call(
            false, purchase.productID, '영수증 검증에 실패했습니다');
      }
    } catch (e, st) {
      AppLogger.error(
        'IAP server verification threw',
        tag: 'IAP',
        error: e,
        stackTrace: st,
      );
      onPurchaseResult?.call(
          false, purchase.productID, '결제 검증 중 오류가 발생했습니다');
    }
  }

  /// 리소스 정리
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    onPurchaseResult = null;
  }
}

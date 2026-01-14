import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../headers/common_app_header.dart';

/// 공통 Screen 기본 클래스
///
/// 모든 Screen에서 사용할 수 있는 기본 구조를 제공합니다.
/// - 일관된 AppBar 구조
/// - 공통 Scaffold 설정
/// - 반복되는 코드 최소화
abstract class BaseScreen extends StatelessWidget {
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? customAppBar;
  final bool safeArea;
  final EdgeInsetsGeometry? padding;

  const BaseScreen({
    super.key,
    this.title,
    this.showBackButton = true,
    this.actions,
    this.floatingActionButton,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
    this.bottomNavigationBar,
    this.customAppBar,
    this.safeArea = true,
    this.padding,
  });

  /// Screen 컨텐츠를 구현하는 추상 메서드
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    Widget content = buildContent(context);

    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    }

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: customAppBar ??
          (title != null
              ? CommonAppHeader(
                  title: title!,
                  showBackButton: showBackButton,
                  actions: actions,
                )
              : null),
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// 스크롤 가능한 Screen 기본 클래스
abstract class ScrollableScreen extends BaseScreen {
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool shrinkWrap;

  const ScrollableScreen({
    super.key,
    super.title,
    super.showBackButton,
    super.actions,
    super.floatingActionButton,
    super.backgroundColor,
    super.extendBodyBehindAppBar,
    super.resizeToAvoidBottomInset,
    super.bottomNavigationBar,
    super.customAppBar,
    super.safeArea,
    super.padding,
    this.physics,
    this.controller,
    this.shrinkWrap = false,
  });

  @override
  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      physics: physics ?? const ClampingScrollPhysics(),
      controller: controller,
      child: buildScrollableContent(context),
    );
  }

  /// 스크롤 가능한 컨텐츠를 구현하는 추상 메서드
  Widget buildScrollableContent(BuildContext context);
}

/// ListView를 사용하는 Screen 기본 클래스
abstract class ListViewScreen extends BaseScreen {
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? listPadding;

  const ListViewScreen({
    super.key,
    super.title,
    super.showBackButton,
    super.actions,
    super.floatingActionButton,
    super.backgroundColor,
    super.extendBodyBehindAppBar,
    super.resizeToAvoidBottomInset,
    super.bottomNavigationBar,
    super.customAppBar,
    super.safeArea,
    super.padding,
    this.physics,
    this.controller,
    this.shrinkWrap = false,
    this.listPadding,
  });

  @override
  Widget buildContent(BuildContext context) {
    return ListView(
      physics: physics ?? const ClampingScrollPhysics(),
      controller: controller,
      shrinkWrap: shrinkWrap,
      padding: listPadding ?? const EdgeInsets.all(16),
      children: buildListItems(context),
    );
  }

  /// ListView의 아이템들을 구현하는 추상 메서드
  List<Widget> buildListItems(BuildContext context);
}

/// StatefulWidget용 공통 Screen 기본 클래스
abstract class BaseStatefulScreen extends StatefulWidget {
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? customAppBar;
  final bool safeArea;
  final EdgeInsetsGeometry? padding;

  const BaseStatefulScreen({
    super.key,
    this.title,
    this.showBackButton = true,
    this.actions,
    this.floatingActionButton,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
    this.bottomNavigationBar,
    this.customAppBar,
    this.safeArea = true,
    this.padding,
  });
}

/// BaseStatefulScreen을 위한 State 기본 클래스
abstract class BaseStatefulScreenState<T extends BaseStatefulScreen>
    extends State<T> {
  /// Screen 컨텐츠를 구현하는 추상 메서드
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    Widget content = buildContent(context);

    if (widget.padding != null) {
      content = Padding(
        padding: widget.padding!,
        child: content,
      );
    }

    if (widget.safeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.white,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      appBar: widget.customAppBar ??
          (widget.title != null
              ? CommonAppHeader(
                  title: widget.title!,
                  showBackButton: widget.showBackButton,
                  actions: widget.actions,
                )
              : null),
      body: content,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}

/// Loading 상태를 포함하는 Screen 기본 클래스
abstract class LoadingScreen extends BaseStatefulScreen {
  const LoadingScreen({
    super.key,
    super.title,
    super.showBackButton,
    super.actions,
    super.floatingActionButton,
    super.backgroundColor,
    super.extendBodyBehindAppBar,
    super.resizeToAvoidBottomInset,
    super.bottomNavigationBar,
    super.customAppBar,
    super.safeArea,
    super.padding,
  });
}

/// LoadingScreen을 위한 State 기본 클래스
abstract class LoadingScreenState<T extends LoadingScreen>
    extends BaseStatefulScreenState<T> {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    if (mounted) {
      setState(() {
        _isLoading = value;
      });
    }
  }

  /// 데이터 로딩을 처리하는 추상 메서드
  Future<void> loadData();

  /// 로딩 완료 후 컨텐츠를 구현하는 추상 메서드
  Widget buildLoadedContent(BuildContext context);

  @override
  void initState() {
    super.initState();
    _loadDataWithLoading();
  }

  Future<void> _loadDataWithLoading() async {
    isLoading = true;
    try {
      await loadData();
    } finally {
      isLoading = false;
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    return buildLoadedContent(context);
  }

  /// 데이터 새로고침
  Future<void> refresh() async {
    await _loadDataWithLoading();
  }
}

library slideview;

import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

part 'slide_view_controller.dart';

///Sort of hack used to make a constant controller.
///PageController also uses this kind of hack.
final SlideController _defaultController = SlideController();

class SlideView extends StatefulWidget {
  ///Creates a page view with infinite scroll.
  ///Scroll can be moved freely forward and backward.
  ///
  ///[children] is required to present slide contents.
  ///If none is given, the view will be empty.
  ///
  ///Internal initial page is at [children.length] * 100.
  ///Going under internal page index 0 is impossible, but for common cases, that situation won't happen.
  ///
  ///[SlideController] can be provided to apply auto sliding and control pages.
  ///If none is given, it's set to default controller with no auto sliding.
  SlideView({
    super.key,
    required this.children,
    this.viewportFraction = 1.0,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    this.findChildIndexCallback,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehavior,
    this.padEnds = true,
    this.indexBuilder,
    SlideController? controller,
  })  : itemBuilder = null,
        itemCount = null,
        controller = controller ?? _defaultController;

  ///Creates a page view with infinite scroll.
  ///Scroll can be moved freely forward and backward.
  ///
  ///[itemBuilder] and [itemCount] is required to present slide contents.
  ///If itemBuilder is not given or itemCount is not a positive, the view will be empty.
  ///
  ///Internal initial page is at [itemCount] * 100, but index passed to itemBuilder will be within itemCount.
  ///Going under internal page index 0 is impossible, but for common cases, that situation won't happen.
  ///
  ///For example, if itemCount is 3, itemBuilder will get {0,1,2} starting from 0.
  ///But if the user scrolls downward for 300 pages, the scroll won't go under it.
  ///It's because the view is built above the [PageView].
  ///
  ///[SlideController] can be provided to apply auto sliding and control pages.
  ///If none is given, it's set to default controller with no auto sliding.
  SlideView.builder({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.viewportFraction = 1.0,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    this.findChildIndexCallback,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehavior,
    this.padEnds = true,
    this.indexBuilder,
    SlideController? controller,
  })  : children = null,
        controller = controller ?? _defaultController;

  @override
  State<SlideView> createState() => _SlideViewState();

  ///The fraction of the viewport that each page should occupy.
  ///Defaults to 1.0, which means each page fills the viewport in the scrolling direction.
  final double viewportFraction;

  ///Direction of the scroll.
  final Axis scrollDirection;

  ///Set to false by default.
  ///If false, scroll will go left to right if [scrollDirection] is [Axis.horizontal].
  ///Also, scroll will go top to bottom if [scrollDirection] is [Axis.vertical].
  ///If set to true, the direction will be opposite.
  final bool reverse;

  ///How the slide view responds to user input.
  final ScrollPhysics? physics;

  ///Set to true by default.
  ///If false, page snapping is disabled.
  final bool pageSnapping;

  ///Callback for page change event.
  ///Event will trigger when the page is
  final void Function(int index)? onPageChanged;

  ///The [findChildIndexCallback] corresponds to the [SliverChildBuilderDelegate.findChildIndexCallback] property.
  ///If null, a child widget may not map to its existing [RenderObject] when the order of children returned from the children builder changes.
  ///This may result in state-loss. This callback needs to be implemented if the order of the children may change at a later time.
  final int? Function(Key key)? findChildIndexCallback;

  ///Set to [DragStartBehavior.start] by default.
  final DragStartBehavior dragStartBehavior;

  ///Set to false by default.
  ///
  ///With this flag set to false, when accessibility focus reaches the end of the current page
  ///and the user attempts to move it to the next element,
  ///the focus will traverse to the next widget outside of the page view.
  ///
  ///With this flag set to true, when accessibility focus reaches the end of the current page
  ///and user attempts to move it to the next element,
  ///focus will traverse to the next page in the page view.
  final bool allowImplicitScrolling;

  ///Restoration ID to save and restore the scroll offset of the scrollable.
  final String? restorationId;

  ///Content cliping option for the slide view.
  ///Set to [Clip.hardEdge] by default.
  final Clip clipBehavior;

  ///A [ScrollBehavior] that will be applied to this widget individually.
  final ScrollBehavior? scrollBehavior;

  ///Whether to add padding to both ends of the list.
  ///Set to true by default.
  ///
  ///If this is set to true and [SlideView.viewportFraction] < 1.0,
  ///padding will be added such that the first and last child slivers will be in the center of the viewport
  ///when scrolled all the way to the start or end, respectively.
  ///
  ///If [SlideView.viewportFraction] >= 1.0, this property has no effect.
  final bool padEnds;

  ///Controller for the [SlideView].
  final SlideController controller;

  ///Builder for Index indicator widget.
  ///
  ///Parameters are context of the widget, index of current page, and the total length of pages.
  final Widget Function(BuildContext context, int index, int length)?
      indexBuilder;

  ///List of Widgets presented inside the SlideView.
  final List<Widget>? children;

  ///Constructor for SlideView contents.
  final Widget Function(BuildContext context, int index)? itemBuilder;
  final int? itemCount;
}

class _SlideViewState extends State<SlideView> {
  late final PageController _pageController;

  int _currentPage = 0;
  final _currentPageNotifier = ValueNotifier(0);

  void initController() {
    _pageController = PageController(
      initialPage: (widget.children != null)
          ? widget.children!.length * 100
          : widget.itemCount! * 100,
      viewportFraction: widget.viewportFraction,
    );

    widget.controller.pageController = _pageController;
  }

  void configAutoSlide() {
    if (widget.controller.autoSlide) {
      widget.controller.startAutoSlide();
    }
  }

  void pageChanged(int index) {
    widget.controller._index = _currentPage;
    _currentPageNotifier.value = _currentPage;
    if (widget.onPageChanged != null) {
      widget.onPageChanged!(index);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initController();
    configAutoSlide();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _fixedListView(context);
  }

  Widget _fixedListView(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _currentPageNotifier,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: widget.scrollDirection,
            reverse: widget.reverse,
            physics: widget.physics,
            pageSnapping: widget.pageSnapping,
            onPageChanged: pageChanged,
            findChildIndexCallback: widget.findChildIndexCallback,
            dragStartBehavior:
                DragStartBehavior.down, //widget.dragStartBehavior,
            allowImplicitScrolling: widget.allowImplicitScrolling,
            restorationId: widget.restorationId,
            clipBehavior: widget.clipBehavior,
            scrollBehavior: widget.scrollBehavior,
            padEnds: widget.padEnds,
            itemBuilder: getItemBuilder(),
          ),
          if (widget.indexBuilder != null) getIndexBuilder(),
        ],
      ),
    );
  }

  Widget? Function(BuildContext, int) getItemBuilder() {
    return (widget.children != null)
        ? (context, index) {
            if (widget.children!.isNotEmpty) {
              _currentPage = index % widget.children!.length;
              return widget.children![index % widget.children!.length];
            }
            return null;
          }
        : (context, index) {
            if (widget.itemCount! > 0 && widget.itemBuilder != null) {
              _currentPage = index % widget.itemCount!;
              return widget.itemBuilder!(context, index % widget.itemCount!);
            }
            return null;
          };
  }

  Widget getIndexBuilder() {
    return Consumer<ValueNotifier<int>>(
      builder: (context, provider, child) {
        return widget.indexBuilder!(
          context,
          provider.value,
          widget.children != null ? widget.children!.length : widget.itemCount!,
        );
      },
    );
  }
}

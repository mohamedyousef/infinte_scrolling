import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinte_scrolling/src/pagination_controller.dart';

typedef ItemWidgetBuilder<ItemType> = Widget Function(
  BuildContext context,
  ItemType item,
  int index,
);

const _circularIndicator = Center(
  child: Center(
    child: CircularProgressIndicator(
      strokeWidth: 0.9,
    ),
  ),
);

class PaginationSliverListView<A, B> extends StatelessWidget {
  final PaginationController<A?, B> controller;
  final ItemWidgetBuilder<B> itemWidgetBuilder;
  final WidgetBuilder? noItemsFoundBuilder;
  final WidgetBuilder? firstPageProgressIndicator;

  const PaginationSliverListView({
    Key? key,
    required this.controller,
    required this.itemWidgetBuilder,
    this.noItemsFoundBuilder,
    this.firstPageProgressIndicator,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    return PagedSliverList<A?, B>(
      pagingController: controller.pagingController,
      builderDelegate: PagedChildBuilderDelegate<B>(
        firstPageProgressIndicatorBuilder: firstPageProgressIndicator ?? (context) => _circularIndicator,
        noItemsFoundIndicatorBuilder: noItemsFoundBuilder,
        newPageProgressIndicatorBuilder: (_) => const Center(child: _circularIndicator),
        itemBuilder: itemWidgetBuilder,
      ),
    );
  }
}

class PaginationSliverGridView<A, B> extends StatelessWidget {
  final PaginationController<A?, B> controller;
  final ItemWidgetBuilder<B> itemWidgetBuilder;
  final double? aspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? itemExtent;
  final int crossAxisCount;
  final ScrollController? scrollController;
  final WidgetBuilder? noItemsFoundBuilder;
  final WidgetBuilder? firstPageProgressIndicator;
  final WidgetBuilder? firstPageErrorIndicatorBuilder;

  const PaginationSliverGridView({
    Key? key,
    this.aspectRatio,
    this.scrollController,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.noItemsFoundBuilder,
    this.firstPageProgressIndicator,
    this.firstPageErrorIndicatorBuilder,
    required this.crossAxisCount,
    required this.controller,
    required this.itemWidgetBuilder,
    this.itemExtent,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    return PagedSliverGrid<A?, B>(
      pagingController: controller.pagingController,
      builderDelegate: PagedChildBuilderDelegate<B>(
        newPageProgressIndicatorBuilder: (_) => const Center(child: _circularIndicator),
        itemBuilder: itemWidgetBuilder,
        noItemsFoundIndicatorBuilder: noItemsFoundBuilder,
        firstPageErrorIndicatorBuilder: firstPageErrorIndicatorBuilder,
        firstPageProgressIndicatorBuilder: firstPageProgressIndicator,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: aspectRatio ?? 1.0,
        crossAxisSpacing: crossAxisSpacing ?? 8,
        mainAxisSpacing: mainAxisSpacing ?? 8,
        crossAxisCount: crossAxisCount,
        mainAxisExtent: itemExtent,
      ),
    );
  }
}

class PaginationListView<A, B> extends StatelessWidget {
  final PaginationController<A?, B> controller;
  final ItemWidgetBuilder<B> itemWidgetBuilder;
  final WidgetBuilder? noItemsFoundBuilder;
  final WidgetBuilder? firstPageProgressIndicator;
  final WidgetBuilder? firstPageErrorIndicatorBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final Axis? scrollDirection;

  final double? itemExtent;
  final EdgeInsets? padding;
  final ScrollController? scrollController;
  final bool reverse;
  final ScrollPhysics? physics;
  final bool? shrinkWrap;

  const PaginationListView({
    Key? key,
    this.itemExtent,
    this.padding,
    this.shrinkWrap,
    this.physics,
    this.reverse = false,
    this.scrollDirection,
    this.scrollController,
    this.noItemsFoundBuilder,
    this.firstPageProgressIndicator,
    this.firstPageErrorIndicatorBuilder,
    required this.controller,
    required this.itemWidgetBuilder,
    this.separatorBuilder,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(() => controller.refresh()),
      child: PagedListView.separated(
        separatorBuilder: separatorBuilder ?? (_, __) => const SizedBox.shrink(),
        padding: padding,
        itemExtent: itemExtent,
        scrollDirection: scrollDirection ?? Axis.vertical,
        reverse: reverse,
        pagingController: controller.pagingController,
        scrollController: scrollController,
        shrinkWrap: shrinkWrap ?? false,
        physics: physics ?? const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        builderDelegate: PagedChildBuilderDelegate<B>(
          noItemsFoundIndicatorBuilder: noItemsFoundBuilder,
          itemBuilder: itemWidgetBuilder,
          firstPageErrorIndicatorBuilder: firstPageErrorIndicatorBuilder,
          firstPageProgressIndicatorBuilder:
              firstPageProgressIndicator ?? (_) => const Center(child: _circularIndicator),
          newPageProgressIndicatorBuilder: (_) => const Center(child: _circularIndicator),
        ),
      ),
    );
  }
}

class PaginationGridView<A, B> extends StatelessWidget {
  final PaginationController<A?, B> controller;
  final ItemWidgetBuilder<B> itemWidgetBuilder;
  final double? aspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? itemExtent;
  final int crossAxisCount;
  final EdgeInsets? padding;
  final ScrollController? scrollController;
  final WidgetBuilder? noItemsFoundBuilder;
  final WidgetBuilder? firstPageProgressIndicator;
  final WidgetBuilder? firstPageErrorIndicatorBuilder;
  final ScrollPhysics? physics;
  final bool? shrinkWrap;

  const PaginationGridView({
    Key? key,
    this.shrinkWrap,
    this.physics,
    this.aspectRatio,
    this.scrollController,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    required this.crossAxisCount,
    this.padding,
    required this.controller,
    required this.itemWidgetBuilder,
    this.itemExtent,
    this.noItemsFoundBuilder,
    this.firstPageProgressIndicator,
    this.firstPageErrorIndicatorBuilder,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      child: PagedGridView<A?, B>(
        pagingController: controller.pagingController,
        scrollController: scrollController,
        physics: physics ?? const BouncingScrollPhysics(),
        padding: padding,
        shrinkWrap: shrinkWrap ?? false,
        builderDelegate: PagedChildBuilderDelegate<B>(
          itemBuilder: itemWidgetBuilder,
          noItemsFoundIndicatorBuilder: noItemsFoundBuilder,
          firstPageErrorIndicatorBuilder: firstPageErrorIndicatorBuilder,
          firstPageProgressIndicatorBuilder:
              firstPageProgressIndicator ?? (_) => const Center(child: _circularIndicator),
          newPageProgressIndicatorBuilder: (_) => const Center(child: _circularIndicator),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: aspectRatio ?? 1.0,
          crossAxisSpacing: crossAxisSpacing ?? 8,
          mainAxisSpacing: mainAxisSpacing ?? 8,
          crossAxisCount: crossAxisCount,
          mainAxisExtent: itemExtent,
        ),
      ),
    );
  }
}

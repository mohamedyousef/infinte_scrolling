import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart' show PagingStatus, PagingStatusExtension;
import 'package:infinte_scrolling/infinte_scrolling.dart';

/// Serves `pageCount` pages of `pageSize` items. Page keys are 1-based and the
/// first request arrives with a null key, as in the apps using this package.
class _NumbersController extends PaginationController<int, String> {
  _NumbersController({this.pageSize = 20, this.pageCount = 3});

  final int pageSize;
  final int pageCount;
  final List<int?> requested = [];
  Object? failWith;

  @override
  Future<void> fetchPage(int? pageKey) async {
    requested.add(pageKey);
    await null;
    final error = failWith;
    if (error != null) {
      failWith = null;
      throw error;
    }
    final page = pageKey ?? 1;
    final items = List.generate(pageSize, (i) => 'item ${(page - 1) * pageSize + i}');
    if (page < pageCount) {
      appendPage(items, page + 1);
    } else {
      appendLastPage(items);
    }
  }
}

void main() {
  group('PaginationPagingController', () {
    late PaginationPagingController<int?, String> controller;
    late List<int?> requests;

    setUp(() {
      controller = PaginationPagingController(firstPageKey: null);
      requests = [];
      controller.addPageRequestListener(requests.add);
    });

    tearDown(() => controller.dispose());

    test('starts empty and waiting for the first page', () {
      expect(controller.itemList, isNull);
      expect(controller.error, isNull);
      expect(controller.nextPageKey, isNull);
      expect(controller.value.status, PagingStatus.loadingFirstPage);
    });

    test('fetchNextPage requests one page at a time', () {
      controller.fetchNextPage();
      controller.fetchNextPage();

      expect(requests, [null]);
      expect(controller.value.isLoading, isTrue);
    });

    test('appendPage adds items and moves to the next key', () {
      controller.fetchNextPage();
      controller.appendPage(['a', 'b'], 2);
      controller.fetchNextPage();
      controller.appendPage(['c'], 3);

      expect(controller.itemList, ['a', 'b', 'c']);
      expect(controller.nextPageKey, 3);
      expect(controller.value.isLoading, isFalse);
      expect(controller.value.status, PagingStatus.ongoing);
      expect(requests, [null, 2]);
    });

    test('appendLastPage completes the list and stops requests', () {
      controller.appendPage(['a'], 2);
      controller.appendLastPage(['b']);
      controller.fetchNextPage();

      expect(controller.itemList, ['a', 'b']);
      expect(controller.nextPageKey, isNull);
      expect(controller.value.status, PagingStatus.completed);
      expect(requests, isEmpty);
    });

    test('an error stops loading, and the next fetch clears it and retries the same key', () {
      controller.appendPage(['a'], 2);
      controller.fetchNextPage();
      controller.error = 'offline';

      expect(controller.value.isLoading, isFalse);
      expect(controller.value.status, PagingStatus.subsequentPageError);

      controller.fetchNextPage();

      expect(controller.error, isNull);
      expect(requests, [2, 2]);
    });

    test('itemList can be replaced, and null goes back to loading the first page', () {
      controller.appendPage(['a', 'b'], 2);

      controller.itemList = ['b'];
      expect(controller.itemList, ['b']);
      expect(controller.nextPageKey, 2);

      controller.itemList = null;
      expect(controller.value.status, PagingStatus.loadingFirstPage);
    });

    test('refresh clears the pages and restarts from the first key', () {
      controller.appendPage(['a'], 2);
      controller.fetchNextPage();
      controller.refresh();

      expect(controller.itemList, isNull);
      expect(controller.nextPageKey, isNull);
      expect(controller.value.isLoading, isFalse);

      controller.fetchNextPage();
      expect(requests, [2, null]);
    });

    test('notifies listeners when the state changes', () {
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.appendPage(['a'], 2);
      controller.error = 'offline';

      expect(notifications, 2);
    });
  });

  group('PaginationController', () {
    test('an exception thrown by fetchPage shows the error state', () async {
      final controller = _NumbersController()..failWith = Exception('offline');
      addTearDown(controller.dispose);

      controller.pagingController.fetchNextPage();
      await pumpEventQueue();

      expect(controller.pagingController.error, isA<Exception>());
      expect(controller.pagingController.value.status, PagingStatus.firstPageError);
    });
  });

  group('widgets', () {
    Widget app(Widget child) => MaterialApp(home: Scaffold(body: child));

    Widget itemBuilder(BuildContext context, String item, int index) => SizedBox(height: 100, child: Text(item));

    testWidgets('PaginationListView loads the first page by itself', (tester) async {
      final controller = _NumbersController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(app(PaginationListView<int, String>(
        controller: controller,
        itemWidgetBuilder: itemBuilder,
      )));
      await tester.pumpAndSettle();

      expect(controller.requested, [null]);
      expect(find.text('item 0'), findsOneWidget);
    });

    testWidgets('PaginationListView requests the next pages while scrolling, then stops', (tester) async {
      final controller = _NumbersController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(app(PaginationListView<int, String>(
        controller: controller,
        itemWidgetBuilder: itemBuilder,
      )));
      await tester.pumpAndSettle();

      for (var i = 0; i < 10; i++) {
        await tester.drag(find.byType(Scrollable), const Offset(0, -3000));
        await tester.pumpAndSettle();
      }

      expect(controller.requested, [null, 2, 3]);
      expect(find.text('item 59'), findsOneWidget);
      expect(controller.pagingController.value.status, PagingStatus.completed);
    });

    testWidgets('a failed first page shows the error indicator, and retry loads it', (tester) async {
      final controller = _NumbersController()..failWith = Exception('offline');
      addTearDown(controller.dispose);

      await tester.pumpWidget(app(PaginationListView<int, String>(
        controller: controller,
        itemWidgetBuilder: itemBuilder,
        firstPageErrorIndicatorBuilder: (_) => TextButton(
          onPressed: controller.pagingController.fetchNextPage,
          child: const Text('retry'),
        ),
      )));
      await tester.pumpAndSettle();

      expect(find.text('retry'), findsOneWidget);

      await tester.tap(find.text('retry'));
      await tester.pumpAndSettle();

      expect(controller.requested, [null, null]);
      expect(find.text('item 0'), findsOneWidget);
    });

    testWidgets('refresh reloads from the first page', (tester) async {
      final controller = _NumbersController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(app(PaginationListView<int, String>(
        controller: controller,
        itemWidgetBuilder: itemBuilder,
      )));
      await tester.pumpAndSettle();

      await controller.refresh();
      await tester.pumpAndSettle();

      expect(controller.requested, [null, null]);
      expect(find.text('item 0'), findsOneWidget);
    });

    testWidgets('replacing itemList updates the list on screen', (tester) async {
      final controller = _NumbersController(pageSize: 3, pageCount: 1);
      addTearDown(controller.dispose);

      await tester.pumpWidget(app(PaginationListView<int, String>(
        controller: controller,
        itemWidgetBuilder: itemBuilder,
      )));
      await tester.pumpAndSettle();

      controller.pagingController.itemList = [...controller.pagingController.itemList!]..removeAt(0);
      await tester.pump();

      expect(find.text('item 0'), findsNothing);
      expect(find.text('item 1'), findsOneWidget);
    });

    testWidgets('PaginationGridView loads and shows items', (tester) async {
      final controller = _NumbersController(pageSize: 4, pageCount: 1);
      addTearDown(controller.dispose);

      await tester.pumpWidget(app(PaginationGridView<int, String>(
        controller: controller,
        crossAxisCount: 2,
        itemWidgetBuilder: itemBuilder,
      )));
      await tester.pumpAndSettle();

      expect(find.text('item 3'), findsOneWidget);
      expect(controller.requested, [null]);
    });

    testWidgets('sliver views load and show items', (tester) async {
      final list = _NumbersController(pageSize: 2, pageCount: 1);
      final grid = _NumbersController(pageSize: 2, pageCount: 1);
      addTearDown(list.dispose);
      addTearDown(grid.dispose);

      await tester.pumpWidget(app(CustomScrollView(
        slivers: [
          PaginationSliverListView<int, String>(controller: list, itemWidgetBuilder: itemBuilder),
          PaginationSliverGridView<int, String>(
            controller: grid,
            crossAxisCount: 2,
            itemWidgetBuilder: (context, item, index) => Text('grid $item'),
          ),
        ],
      )));
      await tester.pumpAndSettle();

      expect(find.text('item 1'), findsOneWidget);
      expect(find.text('grid item 1'), findsOneWidget);
    });

    testWidgets('an empty first page shows the no-items builder', (tester) async {
      final controller = _NumbersController(pageSize: 0, pageCount: 1);
      addTearDown(controller.dispose);

      await tester.pumpWidget(app(PaginationListView<int, String>(
        controller: controller,
        itemWidgetBuilder: itemBuilder,
        noItemsFoundBuilder: (_) => const Text('nothing here'),
      )));
      await tester.pumpAndSettle();

      expect(find.text('nothing here'), findsOneWidget);
    });
  });
}

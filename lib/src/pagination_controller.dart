import 'package:infinte_scrolling/src/pagination_paging_controller.dart';

abstract class PaginationController<A, B> {
  final PaginationPagingController<A?, B> pagingController = PaginationPagingController(firstPageKey: null);

  PaginationController() {
    pagingController.addPageRequestListener(_loadPage);
  }

  /// Loads the page for [pageKey] (null for the first page) and reports the
  /// outcome with [appendPage], [appendLastPage] or [showError].
  Future<void> fetchPage(A? pageKey);

  Future<void> _loadPage(A? pageKey) async {
    try {
      await fetchPage(pageKey);
    } catch (error) {
      // Show the error state instead of a spinner that never stops.
      showError(error);
      // Errors that are not exceptions are bugs: keep them visible.
      if (error is! Exception) rethrow;
    }
  }

  void appendPage(List<B> items, A? nextPageKey) {
    pagingController.appendPage(
      items,
      nextPageKey,
    );
  }

  void appendLastPage(List<B> items) => pagingController.appendLastPage(items);

  Future<void> refresh() async {
    pagingController.refresh();
  }

  void dispose() => pagingController.dispose();
  void showError(error) => pagingController.error = error;
}

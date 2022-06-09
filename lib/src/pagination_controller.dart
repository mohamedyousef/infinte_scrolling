import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

abstract class PaginationController<A, B> {
  final PagingController<A?, B> pagingController = PagingController(firstPageKey: null);

  PaginationController() {
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
  }

  Future<void> fetchPage(A? pageKey);

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

  void showError(error) => pagingController.error = error;
}

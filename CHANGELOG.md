## 2.0.0

* Upgrade `infinite_scroll_pagination` from 4.1.0 to 5.1.1. 4.1.0 no longer
  compiles on Flutter 3.50.
* `PaginationController.pagingController` is now a
  `PaginationPagingController`. It keeps the 4.x members callers use
  (`itemList`, `error`, `nextPageKey`, `appendPage`, `appendLastPage`,
  `refresh`, `addPageRequestListener`, `notifyPageRequestListeners`), and
  its `value` is now the 5.x `PagingState`.
* Pages are requested once at a time; a request made while one is loading
  is ignored.
* An exception thrown by `fetchPage` now shows the error state instead of
  leaving the loading indicator on screen.
* Requires Dart 3.4 / Flutter 3.22 or newer.

## 0.0.1

* TODO: Describe initial release.

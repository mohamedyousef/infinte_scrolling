import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Paging state behind the pagination widgets.
///
/// infinite_scroll_pagination 5.x widgets render a [PagingState] and call
/// `fetchNextPage` when they need more items. This controller produces that
/// state while keeping the push-style API of the 4.x `PagingController` that
/// callers already use: page-request listeners, [appendPage],
/// [appendLastPage], [error] and [itemList].
///
/// All loaded items are kept in a single page, so [itemList] can be read and
/// replaced freely (for example for optimistic updates).
class PaginationPagingController<K, T> extends ValueNotifier<PagingState<K, T>> {
  PaginationPagingController({required K firstPageKey})
      : _firstPageKey = firstPageKey,
        _nextPageKey = firstPageKey,
        super(PagingState<K, T>());

  final K _firstPageKey;
  K? _nextPageKey;
  final List<void Function(K pageKey)> _pageRequestListeners = [];

  /// The loaded items, or null while the first page has not arrived.
  List<T>? get itemList => value.items;

  /// Replaces the loaded items. Null puts the list back in its first-page
  /// loading state.
  set itemList(List<T>? items) {
    value = value.copyWith(
      pages: items == null ? null : [items],
      keys: items == null ? null : [_firstPageKey],
    );
  }

  /// The error of the last request, if it failed.
  Object? get error => value.error;

  /// Marks the current request as failed. The widgets then show their error
  /// indicator, whose retry calls [fetchNextPage].
  set error(Object? error) => value = value.copyWith(error: error, isLoading: false);

  /// The key of the next page to request, or null once the last page loaded.
  K? get nextPageKey => _nextPageKey;

  /// Adds [newItems] after the loaded items. A null [nextPageKey] means this
  /// was the last page.
  void appendPage(List<T> newItems, K? nextPageKey) {
    _nextPageKey = nextPageKey;
    value = value.copyWith(
      pages: [
        [...?itemList, ...newItems],
      ],
      keys: [_firstPageKey],
      error: null,
      hasNextPage: nextPageKey != null,
      isLoading: false,
    );
  }

  /// Adds [newItems] as the final page.
  void appendLastPage(List<T> newItems) => appendPage(newItems, null);

  /// Clears every loaded page; the widgets then request the first page again.
  void refresh() {
    _nextPageKey = _firstPageKey;
    value = value.reset();
  }

  void addPageRequestListener(void Function(K pageKey) listener) => _pageRequestListeners.add(listener);

  void removePageRequestListener(void Function(K pageKey) listener) => _pageRequestListeners.remove(listener);

  /// Asks the listeners to load the page for [pageKey].
  void notifyPageRequestListeners(K pageKey) {
    for (final listener in List.of(_pageRequestListeners)) {
      listener(pageKey);
    }
  }

  /// Requests the next page, unless one is already loading or the last page
  /// has arrived. A previous error is cleared first, which is how the retry
  /// buttons of the widgets work.
  ///
  /// This is the `fetchNextPage` callback given to the 5.x widgets.
  void fetchNextPage() {
    if (value.isLoading) return;
    if (value.pages != null && !value.hasNextPage) return;

    value = value.copyWith(isLoading: true, error: null);
    notifyPageRequestListeners(_nextPageKey as K);
  }

  @override
  void dispose() {
    _pageRequestListeners.clear();
    super.dispose();
  }
}

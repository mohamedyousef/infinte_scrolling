# Infinite Scrolling Package Documentation

A Flutter package that provides a simplified API for implementing infinite scrolling and pagination in your Flutter applications. This package wraps the `infinite_scroll_pagination` package to provide a cleaner, more intuitive interface for paginated lists and grids.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [API Reference](#api-reference)
  - [PaginationController](#paginationcontroller)
  - [PaginationListView](#paginationlistview)
  - [PaginationGridView](#paginationgridview)
  - [PaginationSliverListView](#paginationsliverlistview)
  - [PaginationSliverGridView](#paginationslivergridview)
- [Usage Examples](#usage-examples)
  - [Basic List View](#basic-list-view)
  - [Grid View](#grid-view)
  - [Sliver Views](#sliver-views)
  - [Custom Error Handling](#custom-error-handling)
  - [Custom Loading Indicators](#custom-loading-indicators)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Features

- ✅ **Simple API**: Easy-to-use controller and widget classes
- ✅ **Multiple Layouts**: Support for ListView, GridView, and Sliver variants
- ✅ **Pull-to-Refresh**: Built-in refresh functionality for ListView and GridView
- ✅ **Error Handling**: Customizable error indicators
- ✅ **Loading States**: Configurable loading indicators for first page and subsequent pages
- ✅ **Empty States**: Customizable empty state widgets
- ✅ **Type-Safe**: Full generic type support for page keys and items
- ✅ **Flexible**: Works with any pagination strategy (offset, cursor-based, etc.)

## Installation

Add `infinte_scrolling` to your `pubspec.yaml`:

```yaml
dependencies:
  infinte_scrolling: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

1. **Create a controller** by extending `PaginationController`:

```dart
class MyPaginationController extends PaginationController<int, MyItem> {
  @override
  Future<void> fetchPage(int? pageKey) async {
    try {
      // Fetch your data here
      final items = await fetchItems(pageKey ?? 0);
      final nextPageKey = items.length == pageSize ? (pageKey ?? 0) + items.length : null;
      
      if (nextPageKey == null) {
        appendLastPage(items);
      } else {
        appendPage(items, nextPageKey);
      }
    } catch (error) {
      showError(error);
    }
  }
}
```

2. **Use the widget** in your UI:

```dart
class MyScreen extends StatelessWidget {
  final controller = MyPaginationController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaginationListView<int, MyItem>(
        controller: controller,
        itemWidgetBuilder: (context, item, index) {
          return ListTile(title: Text(item.title));
        },
      ),
    );
  }
}
```

## Architecture

The package follows a simple architecture:

```
PaginationController (Abstract)
    ↓
PagingController (from infinite_scroll_pagination)
    ↓
Pagination Views (ListView, GridView, Sliver variants)
```

### Type Parameters

- **A**: The type of the page key (e.g., `int` for offset-based pagination, `String` for cursor-based)
- **B**: The type of items in your list/grid

## API Reference

### PaginationController

An abstract base class that manages pagination state and logic.

#### Generic Parameters

- `A`: Page key type (nullable)
- `B`: Item type

#### Properties

- `pagingController`: The underlying `PagingController<A?, B>` instance

#### Methods

##### `Future<void> fetchPage(A? pageKey)`

**Abstract method** - Implement this to fetch data for a specific page.

**Parameters:**
- `pageKey`: The key for the page to fetch. `null` indicates the first page.

**Example:**
```dart
@override
Future<void> fetchPage(int? pageKey) async {
  final page = pageKey ?? 0;
  final items = await api.getItems(page: page);
  appendPage(items, page + items.length);
}
```

##### `void appendPage(List<B> items, A? nextPageKey)`

Appends a page of items and sets the next page key.

**Parameters:**
- `items`: List of items to append
- `nextPageKey`: Key for the next page, or `null` if this is the last page

##### `void appendLastPage(List<B> items)`

Appends the final page of items (no more pages available).

**Parameters:**
- `items`: List of items to append

##### `Future<void> refresh()`

Refreshes the pagination by clearing existing data and fetching the first page.

##### `void showError(dynamic error)`

Displays an error state in the pagination view.

**Parameters:**
- `error`: The error object to display

### PaginationListView

A paginated ListView widget with pull-to-refresh support.

#### Constructor

```dart
PaginationListView<A, B>({
  Key? key,
  required PaginationController<A?, B> controller,
  required ItemWidgetBuilder<B> itemWidgetBuilder,
  WidgetBuilder? noItemsFoundBuilder,
  WidgetBuilder? firstPageProgressIndicator,
  WidgetBuilder? firstPageErrorIndicatorBuilder,
  IndexedWidgetBuilder? separatorBuilder,
  Axis? scrollDirection,
  double? itemExtent,
  EdgeInsets? padding,
  ScrollController? scrollController,
  bool reverse = false,
  ScrollPhysics? physics,
  bool? shrinkWrap,
})
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `controller` | `PaginationController<A?, B>` | **Required.** The pagination controller |
| `itemWidgetBuilder` | `ItemWidgetBuilder<B>` | **Required.** Builder for individual items |
| `noItemsFoundBuilder` | `WidgetBuilder?` | Widget to show when no items are found |
| `firstPageProgressIndicator` | `WidgetBuilder?` | Loading indicator for the first page |
| `firstPageErrorIndicatorBuilder` | `WidgetBuilder?` | Error indicator for the first page |
| `separatorBuilder` | `IndexedWidgetBuilder?` | Builder for separators between items |
| `scrollDirection` | `Axis?` | Scroll direction (default: vertical) |
| `itemExtent` | `double?` | Fixed height for items |
| `padding` | `EdgeInsets?` | Padding around the list |
| `scrollController` | `ScrollController?` | Custom scroll controller |
| `reverse` | `bool` | Reverse scroll direction (default: false) |
| `physics` | `ScrollPhysics?` | Scroll physics behavior |
| `shrinkWrap` | `bool?` | Whether to shrink-wrap the list |

### PaginationGridView

A paginated GridView widget with pull-to-refresh support.

#### Constructor

```dart
PaginationGridView<A, B>({
  Key? key,
  required PaginationController<A?, B> controller,
  required ItemWidgetBuilder<B> itemWidgetBuilder,
  required int crossAxisCount,
  double? aspectRatio,
  double? crossAxisSpacing,
  double? mainAxisSpacing,
  double? itemExtent,
  EdgeInsets? padding,
  ScrollController? scrollController,
  WidgetBuilder? noItemsFoundBuilder,
  WidgetBuilder? firstPageProgressIndicator,
  WidgetBuilder? firstPageErrorIndicatorBuilder,
  ScrollPhysics? physics,
  bool? shrinkWrap,
})
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `controller` | `PaginationController<A?, B>` | **Required.** The pagination controller |
| `itemWidgetBuilder` | `ItemWidgetBuilder<B>` | **Required.** Builder for individual items |
| `crossAxisCount` | `int` | **Required.** Number of columns |
| `aspectRatio` | `double?` | Aspect ratio for items (default: 1.0) |
| `crossAxisSpacing` | `double?` | Spacing between columns (default: 8) |
| `mainAxisSpacing` | `double?` | Spacing between rows (default: 8) |
| `itemExtent` | `double?` | Fixed height for items |
| `padding` | `EdgeInsets?` | Padding around the grid |
| `scrollController` | `ScrollController?` | Custom scroll controller |
| `noItemsFoundBuilder` | `WidgetBuilder?` | Widget to show when no items are found |
| `firstPageProgressIndicator` | `WidgetBuilder?` | Loading indicator for the first page |
| `firstPageErrorIndicatorBuilder` | `WidgetBuilder?` | Error indicator for the first page |
| `physics` | `ScrollPhysics?` | Scroll physics behavior |
| `shrinkWrap` | `bool?` | Whether to shrink-wrap the grid |

### PaginationSliverListView

A paginated SliverListView widget for use in CustomScrollView.

#### Constructor

```dart
PaginationSliverListView<A, B>({
  Key? key,
  required PaginationController<A?, B> controller,
  required ItemWidgetBuilder<B> itemWidgetBuilder,
  WidgetBuilder? noItemsFoundBuilder,
  WidgetBuilder? firstPageProgressIndicator,
})
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `controller` | `PaginationController<A?, B>` | **Required.** The pagination controller |
| `itemWidgetBuilder` | `ItemWidgetBuilder<B>` | **Required.** Builder for individual items |
| `noItemsFoundBuilder` | `WidgetBuilder?` | Widget to show when no items are found |
| `firstPageProgressIndicator` | `WidgetBuilder?` | Loading indicator for the first page |

### PaginationSliverGridView

A paginated SliverGridView widget for use in CustomScrollView.

#### Constructor

```dart
PaginationSliverGridView<A, B>({
  Key? key,
  required PaginationController<A?, B> controller,
  required ItemWidgetBuilder<B> itemWidgetBuilder,
  required int crossAxisCount,
  double? aspectRatio,
  double? crossAxisSpacing,
  double? mainAxisSpacing,
  double? itemExtent,
  ScrollController? scrollController,
  WidgetBuilder? noItemsFoundBuilder,
  WidgetBuilder? firstPageProgressIndicator,
  WidgetBuilder? firstPageErrorIndicatorBuilder,
})
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `controller` | `PaginationController<A?, B>` | **Required.** The pagination controller |
| `itemWidgetBuilder` | `ItemWidgetBuilder<B>` | **Required.** Builder for individual items |
| `crossAxisCount` | `int` | **Required.** Number of columns |
| `aspectRatio` | `double?` | Aspect ratio for items (default: 1.0) |
| `crossAxisSpacing` | `double?` | Spacing between columns (default: 8) |
| `mainAxisSpacing` | `double?` | Spacing between rows (default: 8) |
| `itemExtent` | `double?` | Fixed height for items |
| `scrollController` | `ScrollController?` | Custom scroll controller |
| `noItemsFoundBuilder` | `WidgetBuilder?` | Widget to show when no items are found |
| `firstPageProgressIndicator` | `WidgetBuilder?` | Loading indicator for the first page |
| `firstPageErrorIndicatorBuilder` | `WidgetBuilder?` | Error indicator for the first page |

## Usage Examples

### Basic List View

```dart
// Define your item model
class Product {
  final String id;
  final String name;
  final double price;
  
  Product({required this.id, required this.name, required this.price});
}

// Create your controller
class ProductPaginationController extends PaginationController<int, Product> {
  static const pageSize = 20;
  
  @override
  Future<void> fetchPage(int? pageKey) async {
    try {
      final page = pageKey ?? 0;
      final response = await api.getProducts(page: page, limit: pageSize);
      
      if (response.items.length < pageSize) {
        // Last page
        appendLastPage(response.items);
      } else {
        // More pages available
        appendPage(response.items, page + response.items.length);
      }
    } catch (error) {
      showError(error);
    }
  }
}

// Use in your widget
class ProductsScreen extends StatelessWidget {
  final controller = ProductPaginationController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: PaginationListView<int, Product>(
        controller: controller,
        padding: EdgeInsets.all(16),
        itemWidgetBuilder: (context, product, index) {
          return Card(
            child: ListTile(
              title: Text(product.name),
              subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
              leading: CircleAvatar(child: Text(product.id)),
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: 8),
        noItemsFoundBuilder: (context) => Center(
          child: Text('No products found'),
        ),
      ),
    );
  }
}
```

### Grid View

```dart
class ProductGridController extends PaginationController<int, Product> {
  static const pageSize = 20;
  
  @override
  Future<void> fetchPage(int? pageKey) async {
    try {
      final page = pageKey ?? 0;
      final response = await api.getProducts(page: page, limit: pageSize);
      
      if (response.items.length < pageSize) {
        appendLastPage(response.items);
      } else {
        appendPage(response.items, page + response.items.length);
      }
    } catch (error) {
      showError(error);
    }
  }
}

class ProductsGridScreen extends StatelessWidget {
  final controller = ProductGridController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: PaginationGridView<int, Product>(
        controller: controller,
        crossAxisCount: 2,
        aspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        padding: EdgeInsets.all(16),
        itemWidgetBuilder: (context, product, index) {
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey[200],
                    child: Center(child: Text(product.id)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text('\$${product.price.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

### Sliver Views

Use Sliver variants when you need to combine pagination with other sliver widgets:

```dart
class ProductsSliverScreen extends StatelessWidget {
  final controller = ProductPaginationController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Products'),
            floating: true,
            snap: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Featured Products',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          PaginationSliverListView<int, Product>(
            controller: controller,
            itemWidgetBuilder: (context, product, index) {
              return ListTile(
                title: Text(product.name),
                subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### Custom Error Handling

```dart
class ProductsScreen extends StatelessWidget {
  final controller = ProductPaginationController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: PaginationListView<int, Product>(
        controller: controller,
        itemWidgetBuilder: (context, product, index) {
          return ListTile(title: Text(product.name));
        },
        firstPageErrorIndicatorBuilder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Failed to load products',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => controller.refresh(),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Custom Loading Indicators

```dart
PaginationListView<int, Product>(
  controller: controller,
  itemWidgetBuilder: (context, product, index) {
    return ListTile(title: Text(product.name));
  },
  firstPageProgressIndicator: (context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Loading products...'),
      ],
    ),
  ),
)
```

### Cursor-Based Pagination

The package also supports cursor-based pagination:

```dart
class CursorPaginationController extends PaginationController<String?, Product> {
  @override
  Future<void> fetchPage(String? cursor) async {
    try {
      final response = await api.getProducts(cursor: cursor);
      
      if (response.nextCursor == null) {
        appendLastPage(response.items);
      } else {
        appendPage(response.items, response.nextCursor);
      }
    } catch (error) {
      showError(error);
    }
  }
}

// Usage
PaginationListView<String?, Product>(
  controller: CursorPaginationController(),
  itemWidgetBuilder: (context, product, index) {
    return ListTile(title: Text(product.name));
  },
)
```

## Best Practices

1. **Dispose Controllers**: Always dispose controllers when done:

```dart
class _MyScreenState extends State<MyScreen> {
  late final controller = MyPaginationController();
  
  @override
  void dispose() {
    controller.pagingController.dispose();
    super.dispose();
  }
}
```

2. **Error Handling**: Always wrap your fetch logic in try-catch:

```dart
@override
Future<void> fetchPage(int? pageKey) async {
  try {
    // Fetch logic
  } catch (error) {
    showError(error);
  }
}
```

3. **State Management**: Consider using state management solutions (Riverpod, Provider, Bloc) to manage controllers:

```dart
final productControllerProvider = Provider((ref) {
  final controller = ProductPaginationController();
  ref.onDispose(() => controller.pagingController.dispose());
  return controller;
});
```

4. **Performance**: Use `itemExtent` when items have fixed heights for better performance:

```dart
PaginationListView<int, Product>(
  controller: controller,
  itemExtent: 80, // Fixed height
  itemWidgetBuilder: (context, product, index) {
    return ListTile(title: Text(product.name));
  },
)
```

5. **Empty States**: Always provide meaningful empty states:

```dart
noItemsFoundBuilder: (context) => Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.inbox, size: 64, color: Colors.grey),
      SizedBox(height: 16),
      Text('No items found'),
      SizedBox(height: 8),
      Text('Pull down to refresh'),
    ],
  ),
)
```

## Troubleshooting

### Items not loading

- Ensure `fetchPage` is implemented correctly
- Check that you're calling `appendPage` or `appendLastPage` after fetching
- Verify your API is returning data correctly

### Pull-to-refresh not working

- Pull-to-refresh is only available on `PaginationListView` and `PaginationGridView`
- Sliver variants don't support pull-to-refresh (use `RefreshIndicator` with `CustomScrollView`)

### Memory issues with large lists

- Use `itemExtent` for fixed-height items
- Consider implementing item recycling strategies
- Monitor memory usage and adjust page size if needed

### Errors not displaying

- Ensure you're calling `showError(error)` in your catch block
- Provide a custom `firstPageErrorIndicatorBuilder` if needed

## License

See LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.


import 'cart_item.dart';

class Cart {
  final List<CartItem> items;

  const Cart({this.items = const []});

  int get itemCount => items.length;

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  bool containsProduct(String productId) =>
      items.any((item) => item.product.id == productId);

  CartItem? getItem(String productId) {
    try {
      return items.firstWhere((item) => item.product.id == productId);
    } catch (_) {
      return null;
    }
  }

  int getQuantity(String productId) {
    final item = getItem(productId);
    return item?.quantity ?? 0;
  }

  Cart copyWith({List<CartItem>? items}) {
    return Cart(items: items ?? this.items);
  }
}

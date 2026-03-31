import '../../../catalog/models/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  double get unitPrice {
    // Applique le prix de gros si la quantité atteint le seuil
    if (product.bulkPrice != null && 
        product.bulkMinQuantity != null && 
        quantity >= product.bulkMinQuantity!) {
      return product.bulkPrice!;
    }
    return product.unitPrice;
  }

  double get totalPrice => unitPrice * quantity;

  bool get isBulkPrice =>
      product.bulkPrice != null &&
      product.bulkMinQuantity != null &&
      quantity >= product.bulkMinQuantity!;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toOrderItemJson() => {
        'productId': product.id,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          product.id == other.product.id;

  @override
  int get hashCode => product.id.hashCode;
}

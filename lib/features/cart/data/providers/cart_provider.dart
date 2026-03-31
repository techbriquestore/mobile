import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../catalog/models/product.dart';
import '../../domain/models/cart.dart';
import '../../domain/models/cart_item.dart';

/// Provider principal du panier
final cartProvider = NotifierProvider<CartNotifier, Cart>(CartNotifier.new);

/// Provider pour le nombre total d'articles
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).totalQuantity;
});

/// Provider pour le sous-total
final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).subtotal;
});

/// Provider pour vérifier si un produit est dans le panier
final isInCartProvider = Provider.family<bool, String>((ref, productId) {
  return ref.watch(cartProvider).containsProduct(productId);
});

/// Provider pour obtenir la quantité d'un produit dans le panier
final productQuantityInCartProvider = Provider.family<int, String>((ref, productId) {
  return ref.watch(cartProvider).getQuantity(productId);
});

class CartNotifier extends Notifier<Cart> {
  @override
  Cart build() => const Cart();

  /// Ajouter un produit au panier
  void addProduct(Product product, {int quantity = 1}) {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Produit existe déjà, on augmente la quantité
      final updatedItems = [...state.items];
      final existingItem = updatedItems[existingIndex];
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      // Nouveau produit
      state = state.copyWith(
        items: [...state.items, CartItem(product: product, quantity: quantity)],
      );
    }
  }

  /// Retirer un produit du panier
  void removeProduct(String productId) {
    state = state.copyWith(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
  }

  /// Mettre à jour la quantité d'un produit
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  /// Incrémenter la quantité d'un produit
  void incrementQuantity(String productId, {int amount = 1}) {
    final item = state.getItem(productId);
    if (item != null) {
      updateQuantity(productId, item.quantity + amount);
    }
  }

  /// Décrémenter la quantité d'un produit
  void decrementQuantity(String productId, {int amount = 1}) {
    final item = state.getItem(productId);
    if (item != null) {
      final newQuantity = item.quantity - amount;
      if (newQuantity <= 0) {
        removeProduct(productId);
      } else {
        updateQuantity(productId, newQuantity);
      }
    }
  }

  /// Vider le panier
  void clear() {
    state = const Cart();
  }

  /// Obtenir les données pour créer une commande
  List<Map<String, dynamic>> toOrderItems() {
    return state.items.map((item) => item.toOrderItemJson()).toList();
  }
}

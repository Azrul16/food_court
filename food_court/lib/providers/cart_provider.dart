import 'package:flutter/material.dart';
import '../models/dish.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.dish.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(Dish dish) {
    if (_items.containsKey(dish.id)) {
      _items.update(
        dish.id,
        (existingItem) => CartItem(
          dish: existingItem.dish,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        dish.id,
        () => CartItem(dish: dish, quantity: 1),
      );
    }
    notifyListeners();
  }

  void removeItem(String dishId) {
    _items.remove(dishId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final Dish dish;
  final int quantity;

  CartItem({required this.dish, required this.quantity});
}

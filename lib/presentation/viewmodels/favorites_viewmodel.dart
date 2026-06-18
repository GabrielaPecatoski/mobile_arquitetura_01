import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/product.dart';

class FavoritesViewModel extends ChangeNotifier {
  static const _storageKey = 'favorite_products';

  final SharedPreferences _prefs;

  final Map<int, Product> _favorites = {};

  FavoritesViewModel(this._prefs) {
    _load();
  }

  List<Product> get favorites => _favorites.values.toList();

  int get count => _favorites.length;

  bool isFavorite(int id) => _favorites.containsKey(id);

  void toggle(Product product) {
    if (_favorites.containsKey(product.id)) {
      _favorites.remove(product.id);
    } else {
      _favorites[product.id] = product;
    }
    _persist();
    notifyListeners();
  }

  void remove(int id) {
    if (_favorites.remove(id) != null) {
      _persist();
      notifyListeners();
    }
  }

  void _load() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null) return;
    final list = jsonDecode(raw) as List<dynamic>;
    for (final item in list) {
      final product = Product.fromMap(item as Map<String, dynamic>);
      _favorites[product.id] = product;
    }
  }

  Future<void> _persist() async {
    final encoded =
        jsonEncode(_favorites.values.map((p) => p.toMap()).toList());
    await _prefs.setString(_storageKey, encoded);
  }
}

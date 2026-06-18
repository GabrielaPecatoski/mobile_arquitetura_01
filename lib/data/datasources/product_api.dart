import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/product.dart';

class ProductApi {
  static const _baseUrl = 'https://dummyjson.com';
  static const _timeout = Duration(seconds: 10);

  Future<List<Product>> fetchProducts() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/products?limit=30'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar produtos: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawProducts = data['products'] as List<dynamic>;
    return rawProducts
        .map((item) => Product.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<int> createProduct(Product product) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/products/add'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(product.toMap()),
        )
        .timeout(_timeout);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao cadastrar produto: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['id'] as num?)?.toInt() ?? product.id;
  }

  Future<void> updateProduct(Product product) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl/products/${product.id}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(product.toMap()),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar produto: ${response.statusCode}');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http
        .delete(Uri.parse('$_baseUrl/products/$id'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Erro ao remover produto: ${response.statusCode}');
    }
  }
}

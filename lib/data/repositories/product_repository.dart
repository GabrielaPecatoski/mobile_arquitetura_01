import '../../domain/models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({bool forceRefresh = false});

  Future<Product> createProduct(Product product);

  Future<Product> updateProduct(Product product);

  Future<void> deleteProduct(int id);
}

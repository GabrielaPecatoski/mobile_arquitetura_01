import '../../domain/models/product.dart';
import '../cache/product_local_cache.dart';
import '../cache/product_memory_cache.dart';
import '../datasources/product_api.dart';
import 'product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductApi _api;
  final ProductMemoryCache _memoryCache;
  final ProductLocalCache _localCache;

  ProductRepositoryImpl({
    required ProductApi api,
    required ProductMemoryCache memoryCache,
    required ProductLocalCache localCache,
  })  : _api = api,
        _memoryCache = memoryCache,
        _localCache = localCache;

  @override
  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final memory = _memoryCache.products;
      if (memory != null) return memory;

      final local = await _localCache.get();
      if (local != null) {
        _memoryCache.set(local);
        return local;
      }
    }

    final products = await _api.fetchProducts();
    _memoryCache.set(products);
    await _localCache.set(products);
    return products;
  }

  @override
  Future<Product> createProduct(Product product) async {
    final newId = await _api.createProduct(product);
    final created = product.copyWith(id: newId);
    final current = await _currentList();
    await _persist([created, ...current]);
    return created;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    await _api.updateProduct(product);
    final current = await _currentList();
    final updated =
        current.map((p) => p.id == product.id ? product : p).toList();
    await _persist(updated);
    return product;
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _api.deleteProduct(id);
    final current = await _currentList();
    await _persist(current.where((p) => p.id != id).toList());
  }

  Future<List<Product>> _currentList() async {
    final memory = _memoryCache.products;
    if (memory != null) return memory;

    final local = await _localCache.get();
    if (local != null) return local;

    return _api.fetchProducts();
  }

  Future<void> _persist(List<Product> products) async {
    _memoryCache.set(products);
    await _localCache.set(products);
  }
}

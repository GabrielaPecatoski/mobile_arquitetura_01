import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/product.dart';
import '../viewmodels/favorites_viewmodel.dart';
import 'product_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  void _openDetails(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: Consumer<FavoritesViewModel>(
        builder: (context, favorites, _) {
          final products = favorites.favorites;

          if (products.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Você ainda não tem favoritos.',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Toque no coração de um produto para salvá-lo aqui.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: products.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: product.thumbnail,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey.shade200,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                title: Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'R\$ ${product.price.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  onPressed: () => favorites.remove(product.id),
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  tooltip: 'Remover dos favoritos',
                ),
                onTap: () => _openDetails(context, product),
              );
            },
          );
        },
      ),
    );
  }
}

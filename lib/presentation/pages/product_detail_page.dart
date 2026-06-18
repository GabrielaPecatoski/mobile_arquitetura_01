import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/product.dart';
import '../viewmodels/favorites_viewmodel.dart';
import '../viewmodels/product_list_viewmodel.dart';
import 'product_form_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _currentPage = 0;
  late Product _product = widget.product;

  Future<void> _edit() async {
    final updated = await Navigator.push<Product>(
      context,
      MaterialPageRoute(builder: (_) => ProductFormPage(product: _product)),
    );
    if (updated != null && mounted) {
      setState(() => _product = updated);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir produto'),
        content: const Text('Deseja realmente excluir este produto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final vm = context.read<ProductListViewModel>();
    try {
      await vm.deleteProduct(_product.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto removido')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao remover: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Consumer<FavoritesViewModel>(
            builder: (context, favorites, _) {
              final isFavorite = favorites.isFavorite(product.id);
              return IconButton(
                onPressed: () => favorites.toggle(product),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                tooltip: isFavorite
                    ? 'Remover dos favoritos'
                    : 'Adicionar aos favoritos',
              );
            },
          ),
          IconButton(
            onPressed: _edit,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar produto',
          ),
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Excluir produto',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImageGallery(
              images: product.images,
              currentPage: _currentPage,
              onPageChanged: (page) => setState(() => _currentPage = page),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(product.category),
                        avatar: const Icon(Icons.category, size: 16),
                      ),
                      if (product.brand.isNotEmpty)
                        Chip(
                          label: Text(product.brand),
                          avatar: const Icon(Icons.store, size: 16),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'R\$ ${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (product.discountPercentage > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${product.discountPercentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${product.rating.toStringAsFixed(1)}  •  Estoque: ${product.stock}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Descrição',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageGallery extends StatelessWidget {
  final List<String> images;
  final int currentPage;
  final void Function(int) onPageChanged;

  const _ImageGallery({
    required this.images,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.grey.shade100,
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (_, __) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == currentPage ? 10 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == currentPage ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

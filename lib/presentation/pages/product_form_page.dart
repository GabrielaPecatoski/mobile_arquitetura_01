import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/product.dart';
import '../viewmodels/product_list_viewmodel.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _brandController;
  late final TextEditingController _thumbnailController;

  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleController = TextEditingController(text: p?.title ?? '');
    _priceController =
        TextEditingController(text: p != null ? p.price.toString() : '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _brandController = TextEditingController(text: p?.brand ?? '');
    _thumbnailController = TextEditingController(text: p?.thumbnail ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final vm = context.read<ProductListViewModel>();
    final thumbnail = _thumbnailController.text.trim();

    final product = Product(
      id: widget.product?.id ?? 0,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      price: double.parse(_priceController.text.trim().replaceAll(',', '.')),
      rating: widget.product?.rating ?? 0,
      stock: widget.product?.stock ?? 0,
      brand: _brandController.text.trim(),
      thumbnail: thumbnail,
      images: thumbnail.isNotEmpty
          ? [thumbnail]
          : (widget.product?.images ?? const []),
    );

    try {
      if (_isEditing) {
        await vm.updateProduct(product);
      } else {
        await vm.createProduct(product);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Produto atualizado' : 'Produto cadastrado',
          ),
        ),
      );
      Navigator.pop(context, product);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao salvar: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar produto' : 'Novo produto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Preço',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o preço';
                final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
                if (parsed == null) return 'Informe um valor numérico válido';
                if (parsed < 0) return 'O preço não pode ser negativo';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Informe a descrição'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Informe a categoria'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Marca (opcional)',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _thumbnailController,
              decoration: const InputDecoration(
                labelText: 'URL da imagem (opcional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isEditing ? 'Salvar alterações' : 'Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../domain/entities/product.dart';

class ProductForm extends StatefulWidget {
  final Product? product;
  final Function(Product) onSubmit;

  /// When set (artist self-service), the tattoo is auto-assigned to this
  /// artist and the "ID do Tatuador" field is hidden.
  final String? artistId;

  /// Category options (from the database).
  final List<String> categories;

  const ProductForm({
    super.key,
    this.product,
    required this.onSubmit,
    required this.categories,
    this.artistId,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late String _id;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _stockController;
  late TextEditingController _artistIdController;
  late TextEditingController _discountController;
  late TextEditingController _durationController;

  /// Selected category (dropdown of the DB-provided categories).
  String? _category;

  @override
  void initState() {
    super.initState();
    _id =
        widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.product?.imageUrl ?? 'https://via.placeholder.com/150',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );
    _category = widget.categories.contains(widget.product?.category)
        ? widget.product!.category
        : null;
    _artistIdController = TextEditingController(
      text: widget.product?.artistId ?? widget.artistId ?? '',
    );
    _discountController = TextEditingController(
      text: (widget.product?.discountPercent ?? 0) == 0
          ? ''
          : widget.product!.discountPercent.toString(),
    );
    _durationController = TextEditingController(
      text: (widget.product?.durationHours ?? 2).toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _stockController.dispose();
    _artistIdController.dispose();
    _discountController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome do Produto'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o nome do produto';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Descrição'),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira uma descrição';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(
              labelText: 'Preço ao cliente (R\$)',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o preço';
              }
              if (double.tryParse(value) == null) {
                return 'Por favor, insira um valor válido';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _discountController,
            decoration: const InputDecoration(
              labelText: 'Desconto (%)',
              hintText: '0',
              helperText: 'Promoção opcional — o cliente vê o preço já com desconto',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return null;
              final d = int.tryParse(value);
              if (d == null || d < 0 || d > 100) {
                return 'Use um valor entre 0 e 100';
              }
              return null;
            },
          ),
          // Discounted-price hint for the artist (payment is P2P; they keep 100%).
          AnimatedBuilder(
            animation: Listenable.merge([_priceController, _discountController]),
            builder: (context, _) {
              final price = double.tryParse(_priceController.text) ?? 0;
              if (price <= 0) return const SizedBox.shrink();
              final discount =
                  (int.tryParse(_discountController.text) ?? 0).clamp(0, 100);
              if (discount <= 0) return const SizedBox.shrink();
              final effective = price * (1 - discount / 100);
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Cliente paga: R\$ ${effective.toStringAsFixed(2)} '
                  '(de R\$ ${price.toStringAsFixed(2)})',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              );
            },
          ),
          TextFormField(
            controller: _imageUrlController,
            decoration: const InputDecoration(labelText: 'URL da Imagem'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira a URL da imagem';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _stockController,
            decoration: const InputDecoration(labelText: 'Estoque'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira a quantidade em estoque';
              }
              if (int.tryParse(value) == null) {
                return 'Por favor, insira um número válido';
              }
              return null;
            },
          ),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: [
              for (final c in widget.categories)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (value) => setState(() => _category = value),
            validator: (value) =>
                value == null ? 'Selecione uma categoria' : null,
          ),
          TextFormField(
            controller: _durationController,
            decoration: const InputDecoration(
              labelText: 'Duração do serviço (horas)',
              helperText: 'Usado para evitar agendamentos no mesmo horário',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              final d = int.tryParse(value ?? '');
              if (d == null || d < 1 || d > 12) {
                return 'Use de 1 a 12 horas';
              }
              return null;
            },
          ),
          if (widget.artistId == null)
            TextFormField(
              controller: _artistIdController,
              decoration: const InputDecoration(labelText: 'ID do Tatuador'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o ID do tatuador';
                }
                return null;
              },
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final product = Product(
                  id: _id,
                  name: _nameController.text,
                  description: _descriptionController.text,
                  price: double.parse(_priceController.text),
                  imageUrl: _imageUrlController.text,
                  stock: int.parse(_stockController.text),
                  category: _category!,
                  artistId: _artistIdController.text,
                  discountPercent: int.tryParse(_discountController.text) ?? 0,
                  durationHours: int.tryParse(_durationController.text) ?? 2,
                );
                widget.onSubmit(product);
              }
            },
            child: Text(
              widget.product == null
                  ? 'Adicionar Produto'
                  : 'Atualizar Produto',
            ),
          ),
        ],
      ),
    );
  }
}

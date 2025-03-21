import 'package:flutter/material.dart';
import '../../../domain/entities/product.dart';

class ProductForm extends StatefulWidget {
  final Product? product;
  final Function(Product) onSubmit;

  const ProductForm({super.key, this.product, required this.onSubmit});

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late String _id;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _stockController;
  late TextEditingController _categoryController;

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
    _categoryController = TextEditingController(
      text: widget.product?.category ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
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
            decoration: const InputDecoration(labelText: 'Preço (R\$)'),
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
          TextFormField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Categoria'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira a categoria';
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
                  category: _categoryController.text,
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

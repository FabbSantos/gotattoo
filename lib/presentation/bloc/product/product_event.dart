import '../../../domain/entities/product.dart';

abstract class ProductEvent {}

class GetProductsEvent extends ProductEvent {}

class GetProductEvent extends ProductEvent {
  final String id;
  GetProductEvent(this.id);
}

class AddProductEvent extends ProductEvent {
  final Product product;
  AddProductEvent(this.product);
}

class UpdateProductEvent extends ProductEvent {
  final Product product;
  UpdateProductEvent(this.product);
}

class DeleteProductEvent extends ProductEvent {
  final String id;
  DeleteProductEvent(this.id);
}

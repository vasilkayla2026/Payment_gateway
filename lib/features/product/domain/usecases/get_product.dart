import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Loads the product shown on the home screen.
class GetProduct {
  final ProductRepository _repository;

  const GetProduct(this._repository);

  Future<Product> call() => _repository.getProduct();
}

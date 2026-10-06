import '../entities/product.dart';

/// Source of the product on sale.
abstract interface class ProductRepository {
  Future<Product> getProduct();
}

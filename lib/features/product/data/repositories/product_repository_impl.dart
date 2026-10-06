import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource _localDataSource;

  const ProductRepositoryImpl(this._localDataSource);

  @override
  Future<Product> getProduct() async =>
      (await _localDataSource.getProduct()).toEntity();
}

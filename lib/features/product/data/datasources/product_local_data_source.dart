import '../models/product_model.dart';

/// Product data bundled with the app. Add a remote data source next to this
/// one when the catalogue moves to a backend.
abstract interface class ProductLocalDataSource {
  Future<ProductModel> getProduct();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  const ProductLocalDataSourceImpl();

  @override
  Future<ProductModel> getProduct() async =>
      ProductModel.fromJson(_sampleProductJson);
}

/// Shaped like an API response so swapping in a backend is mechanical.
/// Prices are in paise.
const Map<String, dynamic> _sampleProductJson = {
  'id': 'wireless-anc-headphones',
  'name': 'Wireless Noise-Cancelling Headphones',
  'tagline': 'Active noise cancelling · 40-hour battery',
  'description':
      'Shut out the world and focus on what you love. Hybrid active noise '
      'cancellation, plush memory-foam ear cushions and a balanced 40 mm '
      'driver deliver rich sound for flights, commutes and long work '
      'sessions. A single charge lasts up to 40 hours, and ten minutes on '
      'the charger gives you five more.',
  'price': 249900,
  'compareAtPrice': 399900,
  'highlights': [
    'Hybrid active noise cancellation',
    'Up to 40 hours of playback',
    '10-minute fast charge for 5 hours of music',
    'Bluetooth 5.3 with multipoint pairing',
  ],
  'colors': [
    {'name': 'Midnight Black', 'hex': '#263238'},
    {'name': 'Ocean Blue', 'hex': '#1E5AA8'},
    {'name': 'Sandstone', 'hex': '#9C7A5B'},
  ],
  'maxQuantityPerOrder': 5,
};

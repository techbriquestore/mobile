import '../../../core/network/api_client.dart';
import '../models/product.dart';

class ProductService {
  final ApiClient _client;

  ProductService(this._client);

  Future<ProductsPage> getProducts({
    String? search,
    String? category,
    String? status = 'ACTIVE',
    int page = 1,
    int pageSize = 20,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null) 'category': category,
      if (status != null) 'status': status,
    };

    final response = await _client.get('/products', queryParams: params);
    return ProductsPage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> getProductById(String id) async {
    final response = await _client.get('/products/$id');
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> getProductByReference(String reference) async {
    final response = await _client.get('/products/reference/$reference');
    return Product.fromJson(response.data as Map<String, dynamic>);
  }
}

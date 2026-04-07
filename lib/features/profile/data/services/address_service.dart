import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/address_model.dart';

class AddressService {
  final ApiClient _apiClient;

  AddressService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<AddressModel>> getAll() async {
    final response = await _apiClient.get(ApiConstants.addresses);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AddressModel> getById(String id) async {
    final response = await _apiClient.get('${ApiConstants.addresses}/$id');
    return AddressModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AddressModel> create(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.addresses, data: data);
    return AddressModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AddressModel> update(String id, Map<String, dynamic> data) async {
    final response =
        await _apiClient.put('${ApiConstants.addresses}/$id', data: data);
    return AddressModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('${ApiConstants.addresses}/$id');
  }

  Future<void> setDefault(String id) async {
    await _apiClient.patch('${ApiConstants.addresses}/$id/default');
  }
}

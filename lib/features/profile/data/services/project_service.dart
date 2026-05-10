import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/project_model.dart';

class ProjectService {
  final ApiClient _apiClient;

  ProjectService({required ApiClient apiClient}) : _apiClient = apiClient;

  static const String _basePath = '/users/projects';

  Future<List<ProjectModel>> getAll() async {
    final response = await _apiClient.get(_basePath);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProjectModel> getById(String id) async {
    final response = await _apiClient.get('$_basePath/$id');
    return ProjectModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProjectModel> create(Map<String, dynamic> data) async {
    final response = await _apiClient.post(_basePath, data: data);
    return ProjectModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProjectModel> update(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('$_basePath/$id', data: data);
    return ProjectModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('$_basePath/$id');
  }

  Future<void> setDefault(String id) async {
    await _apiClient.patch('$_basePath/$id/default');
  }
}

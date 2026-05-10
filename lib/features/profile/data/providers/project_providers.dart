import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';

// ─── Grand Abidjan cities ───────────────────────────────────────────────
const List<String> grandAbidjanCities = [
  'Abidjan',
  'Dabou',
  'Jacqueville',
  'Agboville',
  'Bonoua',
  'Grand-Bassam',
  'Bingerville',
  'Anyama',
  'Songon',
  'Alépé',
  'Azaguié',
  'Tiassalé',
  'Sikensi',
  'Grand-Lahou',
];

// ─── Communes d'Abidjan ─────────────────────────────────────────────────
const List<String> abidjanCommunes = [
  'Abobo',
  'Adjamé',
  'Attécoubé',
  'Cocody',
  'Koumassi',
  'Marcory',
  'Plateau',
  'Port-Bouët',
  'Treichville',
  'Yopougon',
  'Songon',
  'Anyama',
  'Bingerville',
];

// ─── Service Provider ───────────────────────────────────────────────────
final projectServiceProvider = Provider<ProjectService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProjectService(apiClient: apiClient);
});

// ─── Project State ──────────────────────────────────────────────────────
enum ProjectStatus { initial, loading, loaded, error }

class ProjectState {
  final ProjectStatus status;
  final List<ProjectModel> projects;
  final String? errorMessage;

  const ProjectState({
    this.status = ProjectStatus.initial,
    this.projects = const [],
    this.errorMessage,
  });

  ProjectState copyWith({
    ProjectStatus? status,
    List<ProjectModel>? projects,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProjectState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  ProjectModel? get defaultProject {
    try {
      return projects.firstWhere((p) => p.isDefault);
    } catch (_) {
      return projects.isNotEmpty ? projects.first : null;
    }
  }
}

// ─── Project Notifier ───────────────────────────────────────────────────
class ProjectNotifier extends Notifier<ProjectState> {
  @override
  ProjectState build() {
    return const ProjectState();
  }

  ProjectService get _service => ref.read(projectServiceProvider);

  Future<void> loadProjects() async {
    state = state.copyWith(status: ProjectStatus.loading, clearError: true);
    try {
      final projects = await _service.getAll();
      state = ProjectState(
        status: ProjectStatus.loaded,
        projects: projects,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProjectStatus.error,
        errorMessage: _extractError(e),
      );
    }
  }

  Future<bool> createProject(Map<String, dynamic> data) async {
    try {
      await _service.create(data);
      await loadProjects();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _extractError(e));
      return false;
    }
  }

  Future<bool> updateProject(String id, Map<String, dynamic> data) async {
    try {
      await _service.update(id, data);
      await loadProjects();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _extractError(e));
      return false;
    }
  }

  Future<bool> deleteProject(String id) async {
    try {
      await _service.delete(id);
      await loadProjects();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _extractError(e));
      return false;
    }
  }

  Future<bool> setDefault(String id) async {
    try {
      await _service.setDefault(id);
      await loadProjects();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _extractError(e));
      return false;
    }
  }

  String _extractError(dynamic error) {
    if (error is Exception) {
      final str = error.toString();
      if (str.contains('message:')) {
        final match = RegExp(r'message:\s*(.+?)(?:,|$)').firstMatch(str);
        if (match != null) return match.group(1)?.trim() ?? 'Erreur inconnue';
      }
      return str.replaceAll('Exception: ', '');
    }
    return error?.toString() ?? 'Erreur inconnue';
  }
}

// ─── Provider ───────────────────────────────────────────────────────────
final projectProvider =
    NotifierProvider<ProjectNotifier, ProjectState>(ProjectNotifier.new);

// ─── Project Detail Provider (avec KPIs) ────────────────────────────────
final projectDetailProvider = FutureProvider.family<ProjectModel, String>((ref, id) async {
  final service = ref.read(projectServiceProvider);
  return service.getById(id);
});

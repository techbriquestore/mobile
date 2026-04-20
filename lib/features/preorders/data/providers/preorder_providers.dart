import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/models/preorder.dart';
import '../services/preorder_service.dart';

// ─── Service provider ─────────────────────────────────────────────────────────

final preorderServiceProvider = Provider<PreorderService>((ref) {
  return PreorderService(ServiceLocator.apiClient);
});

// ─── Filtres ──────────────────────────────────────────────────────────────────

class PreorderFilters {
  final String? status;
  final String? search;
  final int page;

  const PreorderFilters({this.status, this.search, this.page = 1});

  PreorderFilters copyWith({
    String? status,
    String? search,
    int? page,
    bool clearStatus = false,
    bool clearSearch = false,
  }) {
    return PreorderFilters(
      status: clearStatus ? null : (status ?? this.status),
      search: clearSearch ? null : (search ?? this.search),
      page: page ?? this.page,
    );
  }
}

class PreorderFiltersNotifier extends Notifier<PreorderFilters> {
  @override
  PreorderFilters build() => const PreorderFilters();

  void setStatus(String? value) {
    state = state.copyWith(status: value, clearStatus: value == null, page: 1);
  }

  void setSearch(String? value) {
    state = state.copyWith(
      search: value,
      clearSearch: value == null || value.isEmpty,
      page: 1,
    );
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }

  void reset() {
    state = const PreorderFilters();
  }
}

final preorderFiltersProvider =
    NotifierProvider<PreorderFiltersNotifier, PreorderFilters>(
  PreorderFiltersNotifier.new,
);

// ─── Provider liste pré-commandes ─────────────────────────────────────────────

final preordersProvider = FutureProvider.autoDispose<PreordersPage>((ref) async {
  final service = ref.read(preorderServiceProvider);
  final filters = ref.watch(preorderFiltersProvider);

  return service.getPreorders(
    status: filters.status,
    search: filters.search,
    page: filters.page,
  );
});

// ─── Provider détail pré-commande ─────────────────────────────────────────────

final preorderByIdProvider =
    FutureProvider.autoDispose.family<PreorderDetail, String>((ref, id) async {
  final service = ref.read(preorderServiceProvider);
  return service.getPreorderById(id);
});

// ─── Provider pour payer une échéance ───────────────────────────────────────────

final payScheduleProvider =
    FutureProvider.autoDispose.family<PreorderSchedule, String>((ref, scheduleId) async {
  final service = ref.read(preorderServiceProvider);
  return service.paySchedule(scheduleId);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';

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
final addressServiceProvider = Provider<AddressService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AddressService(apiClient: apiClient);
});

// ─── Address State ──────────────────────────────────────────────────────
enum AddressStatus { initial, loading, loaded, error }

class AddressState {
  final AddressStatus status;
  final List<AddressModel> addresses;
  final String? errorMessage;

  const AddressState({
    this.status = AddressStatus.initial,
    this.addresses = const [],
    this.errorMessage,
  });

  AddressState copyWith({
    AddressStatus? status,
    List<AddressModel>? addresses,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddressState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  AddressModel? get defaultAddress {
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }
}

// ─── Address Notifier ───────────────────────────────────────────────────
class AddressNotifier extends Notifier<AddressState> {
  @override
  AddressState build() {
    return const AddressState();
  }

  AddressService get _service => ref.read(addressServiceProvider);

  Future<void> loadAddresses() async {
    state = state.copyWith(status: AddressStatus.loading, clearError: true);
    try {
      final addresses = await _service.getAll();
      state = AddressState(
        status: AddressStatus.loaded,
        addresses: addresses,
      );
    } catch (e) {
      state = state.copyWith(
        status: AddressStatus.error,
        errorMessage: _extractError(e),
      );
    }
  }

  Future<bool> createAddress(Map<String, dynamic> data) async {
    try {
      await _service.create(data);
      await loadAddresses();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _extractError(e));
      return false;
    }
  }

  Future<bool> updateAddress(String id, Map<String, dynamic> data) async {
    try {
      await _service.update(id, data);
      await loadAddresses();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _extractError(e));
      return false;
    }
  }

  Future<bool> deleteAddress(String id) async {
    try {
      await _service.delete(id);
      await loadAddresses();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _extractError(e));
      return false;
    }
  }

  Future<bool> setDefault(String id) async {
    try {
      await _service.setDefault(id);
      await loadAddresses();
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
final addressProvider =
    NotifierProvider<AddressNotifier, AddressState>(AddressNotifier.new);

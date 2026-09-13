import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leavelist/features/home/data/home_service_provider.dart';
import 'package:leavelist/features/home/models/address_mapper.dart';
import 'package:leavelist/features/home/models/map_pin.dart';
import 'package:leavelist/features/home/provider/bootstrap_provider.dart';
import 'package:leavelist/features/home/provider/home_state.dart';

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    final bootstrap = ref.watch(bootstrapProvider);
    final merged = bootstrap.value ?? const [];
    return HomeState(pins: merged.map((m) => m.address.toMapPin()).toList());
  }

  Future<void> addPin(MapPin pin) async {
    state = state.copyWith(pins: [...state.pins, pin]);

    try {
      final service = ref.read(homeServiceProvider);
      await service.saveAddress(pin.toAddressModel());
      await ref.read(bootstrapProvider.notifier).refresh();
    } catch (e, st) {
      debugPrint('[HomeNotifier] addPin failed to persist: $e\n$st');
    }
  }

  Future<void> removePin(String pinId) async {
    state = state.copyWith(
      pins: state.pins.where((p) => p.id != pinId).toList(),
      selectedPinId: state.selectedPinId == pinId ? null : state.selectedPinId,
      clearSelectedPinId: state.selectedPinId == pinId,
    );

    try {
      final service = ref.read(homeServiceProvider);
      await service.deleteAddress(pinId);
      await service.deleteTodoList(pinId);
      await ref.read(bootstrapProvider.notifier).refresh();
    } catch (e, st) {
      debugPrint('[HomeNotifier] removePin failed to persist: $e\n$st');
    }
  }

  void selectPin(String? pinId) {
    state = state.copyWith(selectedPinId: pinId, clearSelectedPinId: pinId == null);
  }
}

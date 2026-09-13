import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leavelist/features/home/data/home_service_provider.dart';
import 'package:leavelist/features/home/models/address_with_checklist.dart';
import 'package:leavelist/features/home/models/checklist_item.dart';

/// Loads every saved address and merges each with its persisted checklist,
/// so downstream state (see [TodoNotifier]) always starts from data that's
/// already been reconciled against storage.
class BootstrapNotifier extends AsyncNotifier<List<AddressWithChecklist>> {
  @override
  Future<List<AddressWithChecklist>> build() async {
    final service = ref.watch(homeServiceProvider);
    final addresses = await service.getAddresses();

    debugPrint('[Bootstrap] loaded ${addresses.length} address(es): '
        '${addresses.map((a) => a.id).toList()}');

    final merged = <AddressWithChecklist>[];
    for (final address in addresses) {
      List<ChecklistItem> items = const [];
      try {
        items = (await service.getTodoList(address.id)).checklist;
      } on StateError {
        items = const [];
      }
      merged.add(AddressWithChecklist(address: address, items: items));
    }

    return merged;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

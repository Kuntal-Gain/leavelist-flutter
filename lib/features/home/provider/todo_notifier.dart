import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leavelist/features/home/data/home_service_provider.dart';
import 'package:leavelist/features/home/models/checklist_item.dart';
import 'package:leavelist/features/home/provider/bootstrap_provider.dart';
import 'package:leavelist/features/home/provider/todo_state.dart';

class TodoNotifier extends Notifier<TodoState> {
  @override
  TodoState build() {
    final bootstrap = ref.watch(bootstrapProvider);
    return TodoState(addresses: bootstrap.value ?? const []);
  }

  void selectAddress(String? addrId) {
    state = state.copyWith(selectedAddrId: addrId, clearSelectedAddrId: addrId == null);
  }

  Future<void> setChecklistItems(String addrId, List<ChecklistItem> items) async {
    final updated = [
      for (final entry in state.addresses)
        entry.address.id == addrId ? entry.copyWith(items: items) : entry,
    ];
    state = state.copyWith(addresses: updated);

    final service = ref.read(homeServiceProvider);
    await service.saveTodoList(CheckList(addrId: addrId, checklist: items));
  }

  Future<void> clearChecklist(String addrId) async {
    final updated = [
      for (final entry in state.addresses)
        entry.address.id == addrId ? entry.copyWith(items: const []) : entry,
    ];
    state = state.copyWith(addresses: updated);

    final service = ref.read(homeServiceProvider);
    await service.deleteTodoList(addrId);
  }
}

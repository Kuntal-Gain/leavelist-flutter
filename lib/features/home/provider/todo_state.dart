import 'package:leavelist/features/home/models/address_with_checklist.dart';
import 'package:leavelist/features/home/models/checklist_item.dart';

class TodoState {
  final List<AddressWithChecklist> addresses;
  final String? selectedAddrId;

  const TodoState({
    this.addresses = const [],
    this.selectedAddrId,
  });

  List<ChecklistItem> itemsFor(String addrId) {
    for (final entry in addresses) {
      if (entry.address.id == addrId) return entry.items;
    }
    return const [];
  }

  TodoState copyWith({
    List<AddressWithChecklist>? addresses,
    String? selectedAddrId,
    bool clearSelectedAddrId = false,
  }) {
    return TodoState(
      addresses: addresses ?? this.addresses,
      selectedAddrId: clearSelectedAddrId ? null : (selectedAddrId ?? this.selectedAddrId),
    );
  }
}

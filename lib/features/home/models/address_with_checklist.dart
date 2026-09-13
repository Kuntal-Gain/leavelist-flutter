import 'package:leavelist/features/home/models/address_model.dart';
import 'package:leavelist/features/home/models/checklist_item.dart';

/// Merges an [AddressModel] with the [CheckList] configured for it, so the
/// UI can render an address alongside its todo items in one shot.
class AddressWithChecklist {
  final AddressModel address;
  final List<ChecklistItem> items;

  const AddressWithChecklist({
    required this.address,
    this.items = const [],
  });

  AddressWithChecklist copyWith({
    AddressModel? address,
    List<ChecklistItem>? items,
  }) {
    return AddressWithChecklist(
      address: address ?? this.address,
      items: items ?? this.items,
    );
  }
}

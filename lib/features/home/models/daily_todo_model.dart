import 'package:hive/hive.dart';
import 'package:leavelist/features/home/models/checklist_item.dart';

part 'daily_todo_model.g.dart';

/// Snapshot of an address's checklist for one particular day, so completion
/// state can be tracked per day without touching the base [CheckList].
@HiveType(typeId: 5)
class DailyTodoModel {
  /// Id of the address this todo belongs to.
  @HiveField(0)
  final String addressId;

  /// Day this snapshot applies to, formatted `yyyy-MM-dd`.
  @HiveField(1)
  final String date;

  @HiveField(2)
  final List<ChecklistItem> items;

  const DailyTodoModel({
    required this.addressId,
    required this.date,
    this.items = const [],
  });

  /// Box key: one entry per address per day.
  String get id => keyFor(addressId, date);

  static String keyFor(String addressId, String date) => '${addressId}_$date';

  DailyTodoModel copyWith({List<ChecklistItem>? items}) {
    return DailyTodoModel(
      addressId: addressId,
      date: date,
      items: items ?? this.items,
    );
  }
}

import 'package:leavelist/features/home/models/checklist_item.dart';
import 'package:leavelist/features/home/models/daily_todo_model.dart';

class DailyTodoState {
  /// Today's loaded todos, keyed by address id.
  final Map<String, DailyTodoModel> todos;

  const DailyTodoState({this.todos = const {}});

  List<ChecklistItem> itemsFor(String addrId) =>
      todos[addrId]?.items ?? const [];

  int doneCount(String addrId) =>
      itemsFor(addrId).where((item) => item.isDone).length;

  bool isAllDone(String addrId) {
    final items = itemsFor(addrId);
    return items.isNotEmpty && items.every((item) => item.isDone);
  }

  DailyTodoState copyWith({Map<String, DailyTodoModel>? todos}) {
    return DailyTodoState(todos: todos ?? this.todos);
  }
}

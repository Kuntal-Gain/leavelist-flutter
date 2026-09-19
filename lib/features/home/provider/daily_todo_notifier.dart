import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leavelist/features/home/data/home_service_provider.dart';
import 'package:leavelist/features/home/models/daily_todo_model.dart';
import 'package:leavelist/features/home/provider/daily_todo_state.dart';

class DailyTodoNotifier extends Notifier<DailyTodoState> {
  @override
  DailyTodoState build() => const DailyTodoState();

  void _put(DailyTodoModel todo) {
    state = state.copyWith(todos: {...state.todos, todo.addressId: todo});
  }

  /// Loads today's todo for [addrId], creating it from the base checklist
  /// on first access of the day.
  Future<void> load(String addrId) async {
    final todo = await ref.read(homeServiceProvider).getDailyTodo(addrId);
    _put(todo);
  }

  /// Flips the done state of one item and persists it.
  Future<void> toggleItem(String addrId, String itemId) async {
    final current = state.todos[addrId];
    if (current == null) return;

    final updated = current.copyWith(
      items: [
        for (final item in current.items)
          item.id == itemId ? item.copyWith(isDone: !item.isDone) : item,
      ],
    );
    _put(updated);

    await ref.read(homeServiceProvider).updateDailyTodo(updated);
  }

  /// Discards today's progress; the next [load] rebuilds it from the base
  /// checklist.
  Future<void> reset(String addrId) async {
    await ref.read(homeServiceProvider).deleteDailyTodo(addrId);
    await load(addrId);
  }
}

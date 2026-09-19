import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leavelist/features/home/provider/daily_todo_notifier.dart';
import 'package:leavelist/features/home/provider/daily_todo_state.dart';

final dailyTodoProvider =
    NotifierProvider<DailyTodoNotifier, DailyTodoState>(DailyTodoNotifier.new);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leavelist/features/home/provider/todo_notifier.dart';
import 'package:leavelist/features/home/provider/todo_state.dart';

final todoProvider = NotifierProvider<TodoNotifier, TodoState>(TodoNotifier.new);

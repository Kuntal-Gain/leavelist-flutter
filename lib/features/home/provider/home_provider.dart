import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leavelist/features/home/provider/home_notifier.dart';
import 'package:leavelist/features/home/provider/home_state.dart';

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);

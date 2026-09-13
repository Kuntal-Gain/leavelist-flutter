import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leavelist/features/home/models/address_with_checklist.dart';
import 'package:leavelist/features/home/provider/bootstrap_notifier.dart';

final bootstrapProvider =
    AsyncNotifierProvider<BootstrapNotifier, List<AddressWithChecklist>>(
  BootstrapNotifier.new,
);

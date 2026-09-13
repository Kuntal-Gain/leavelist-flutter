import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leavelist/features/home/data/home_service.dart';
import 'package:leavelist/features/home/data/home_service_impl.dart';

final homeServiceProvider = Provider<HomeService>((ref) => HomeServiceImpl());

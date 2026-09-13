import 'package:hive_flutter/hive_flutter.dart';
import 'package:leavelist/features/home/models/address_model.dart';
import 'package:leavelist/features/home/models/checklist_item.dart';
import 'package:leavelist/core/constants/app_storage_box.dart';

/// Thin wrapper around Hive setup — initialization, adapter registration,
/// and box access. Models bring their own generated `TypeAdapter`s (via
/// `@HiveType`/`@HiveField` + `build_runner`) and register them through
/// [LocalStorageService.init].
class LocalStorageService {
  LocalStorageService._();

  static bool _initialized = false;
  static final Map<String, Box> _openBoxes = {};

  /// Call once in `main()` before `runApp`, passing every generated adapter
  /// the app needs, e.g.:
  /// ```dart
  /// await LocalStorageService.init(adapters: [
  ///   AddressEntityAdapter(),
  ///   ChecklistItemEntityAdapter(),
  /// ]);
  /// ```
  // static Future<void> init({List<TypeAdapter>? adapters}) async {
  //   if (_initialized) return;

  //   await Hive.initFlutter();
  //   debugPrint('[LocalStorageService] Hive.initFlutter done');

  //   for (final adapter in adapters ?? const []) {
  //     if (!Hive.isAdapterRegistered(adapter.typeId)) {
  //       Hive.registerAdapter(adapter);
  //       debugPrint('[LocalStorageService] registered adapter typeId=${adapter.typeId} (${adapter.runtimeType})');
  //     }
  //   }

  //   _initialized = true;
  // }

static Future<void> init() async {
  if (_initialized) return;

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter<AddressType>(AddressTypeAdapter());
  }

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter<AddressModel>(AddressModelAdapter());
  }

  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter<ItemType>(ItemTypeAdapter());
  }

  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter<CheckList>(CheckListAdapter());
  }

  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter<ChecklistItem>(ChecklistItemAdapter());
  }

  _openBoxes[AppStorageBox.addresses] =
      await Hive.openBox<AddressModel>(AppStorageBox.addresses);
  _openBoxes[AppStorageBox.checklists] =
      await Hive.openBox<CheckList>(AppStorageBox.checklists);

  _initialized = true;
}

  /// Synchronously returns the already-opened box for [name].
  /// Every box is opened once in [init], before `runApp`.
  static Box<T> box<T>(String name) => Hive.box<T>(name);

  static bool isBoxOpen(String name) => Hive.isBoxOpen(name);

  static Future<void> closeBox(String name) async {
    if (Hive.isBoxOpen(name)) {
      await Hive.box(name).close();
      _openBoxes.remove(name);
    }
  }

  static Future<void> deleteBoxFromDisk(String name) async {
    await Hive.deleteBoxFromDisk(name);
    _openBoxes.remove(name);
  }

  /// Clears every open box and Hive's local storage. Use with care.
  static Future<void> clearAll() async {
    for (final box in _openBoxes.values) {
      await box.clear();
    }
  }
}

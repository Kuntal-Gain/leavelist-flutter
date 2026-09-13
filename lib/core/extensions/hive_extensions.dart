import 'package:hive_flutter/hive_flutter.dart';

/// Convenience helpers over [Box], so call sites don't repeat
/// `box.values.toList()` / listener boilerplate everywhere.
extension HiveBoxX<T> on Box<T> {
  /// All values currently in the box, as a plain list.
  List<T> getAll() => values.toList();

  /// Adds [value] keyed by [key] (upsert semantics — same as [Box.put]).
  Future<void> upsert(String key, T value) => put(key, value);

  Future<void> removeByKey(String key) => delete(key);

  /// Emits the full list of values whenever the box changes, including once
  /// immediately with the current contents.
  Stream<List<T>> watchAll() async* {
    yield getAll();
    yield* watch().map((_) => getAll());
  }
}

/// Same helpers, scoped to a [HiveObject] entry so keys are managed for you.
extension HiveObjectBoxX<T extends HiveObject> on Box<T> {
  Future<void> upsertObject(T value) => add(value);

  Future<void> removeObject(T value) => value.delete();
}

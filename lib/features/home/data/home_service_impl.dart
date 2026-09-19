import 'package:hive/hive.dart';
import 'package:leavelist/core/constants/app_storage_box.dart';
import 'package:leavelist/features/home/data/home_service.dart';
import 'package:leavelist/features/home/models/address_model.dart';
import 'package:leavelist/core/services/local_storage_service.dart';
import 'package:leavelist/features/home/models/checklist_item.dart';
import 'package:leavelist/features/home/models/daily_todo_model.dart';

class HomeServiceImpl implements HomeService {
  HomeServiceImpl();

  @override
  Future<List<AddressModel>> getAddresses() async {
    final box = LocalStorageService.box<AddressModel>(AppStorageBox.addresses);

    return box.values.toList();
  }

  @override
  Future<void> saveAddress(AddressModel address) async {
    final box = LocalStorageService.box<AddressModel>(AppStorageBox.addresses);

    await box.put(address.id, address);
  }

  @override
  Future<void> deleteAddress(String id) async {
    final box = LocalStorageService.box<AddressModel>(AppStorageBox.addresses);

    await box.delete(id);
  }

  @override
  Future<void> updateAddress(AddressModel address) async {
    final box = LocalStorageService.box<AddressModel>(AppStorageBox.addresses);

    await box.put(address.id, address);
  }

  @override
  Future<void> deleteTodoList(String addrId) async {
    final box = LocalStorageService.box<CheckList>(AppStorageBox.checklists);

    await box.delete(addrId);
  }

  @override
  Future<CheckList> getTodoList(String addrId) async {
    final box = LocalStorageService.box<CheckList>(AppStorageBox.checklists);

    return box.get(addrId) ?? CheckList(addrId: addrId, checklist: const []);
  }

  @override
  Future<void> saveTodoList(CheckList todoList) async {
    final box = LocalStorageService.box<CheckList>(AppStorageBox.checklists);

    await box.put(todoList.addrId, todoList);
  }

  @override
  Future<void> updateTodoList(CheckList todoList) async {
    final box = LocalStorageService.box<CheckList>(AppStorageBox.checklists);

    await box.put(todoList.addrId, todoList);
  }

  /// Today's date as `yyyy-MM-dd`.
  String get _today {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  Box<DailyTodoModel> get _dailyBox =>
      LocalStorageService.box<DailyTodoModel>(AppStorageBox.dailyTodos);

  /// Returns today's todo for [addrId]. On first access of the day it is
  /// created from the address's base checklist with every item not done.
  @override
  Future<DailyTodoModel> getDailyTodo(String addrId) async {
    final date = _today;
    final key = DailyTodoModel.keyFor(addrId, date);

    final existing = _dailyBox.get(key);
    // An empty snapshot is rebuilt so items added to the checklist later
    // still show up today.
    if (existing != null && existing.items.isNotEmpty) return existing;

    final base = await getTodoList(addrId);
    final daily = DailyTodoModel(
      addressId: addrId,
      date: date,
      items: [for (final item in base.checklist) item.copyWith(isDone: false)],
    );
    await _dailyBox.put(key, daily);

    return daily;
  }

  @override
  Future<void> saveDailyTodo(DailyTodoModel dailyTodo) async {
    await _dailyBox.put(dailyTodo.id, dailyTodo);
  }

  @override
  Future<void> updateDailyTodo(DailyTodoModel dailyTodo) async {
    await _dailyBox.put(dailyTodo.id, dailyTodo);
  }

  @override
  Future<void> deleteDailyTodo(String addrId) async {
    await _dailyBox.delete(DailyTodoModel.keyFor(addrId, _today));
  }
}

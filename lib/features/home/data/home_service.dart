import 'package:leavelist/features/home/models/address_model.dart';
import 'package:leavelist/features/home/models/checklist_item.dart';
import 'package:leavelist/features/home/models/daily_todo_model.dart';

abstract class HomeService {

  /// [ADDRESS] service

  /// Retrieve all addresses from local storage
  Future<List<AddressModel>> getAddresses();
  
  /// Save address to local storage
  Future<void> saveAddress(AddressModel address);
  
  /// Delete address from local storage
  Future<void> deleteAddress(String id);
  
  /// Update address in local storage
  Future<void> updateAddress(AddressModel address);

  /// [TODO] service
  
  /// Retrieve Todo List by a specific Address
  Future<CheckList> getTodoList(String addrId);

  /// Save Todo List for a specific Address
  Future<void> saveTodoList(CheckList todoList);

  /// Update Todo List for a specific Address
  Future<void> updateTodoList(CheckList todoList);

  /// Delete Todo List for a specific Address
  Future<void> deleteTodoList(String addrId);

  /// Get daily todo for a current date
  Future<DailyTodoModel> getDailyTodo(String addrId);

  /// Save daily todo for a current date
  Future<void> saveDailyTodo(DailyTodoModel dailyTodo);

  /// Update daily todo for a current date
  Future<void> updateDailyTodo(DailyTodoModel dailyTodo);

  /// Delete daily todo for a current date
  Future<void> deleteDailyTodo(String addrId);
}

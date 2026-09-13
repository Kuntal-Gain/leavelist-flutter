import 'package:leavelist/core/constants/app_storage_box.dart';
import 'package:leavelist/features/home/data/home_service.dart';
import 'package:leavelist/features/home/models/address_model.dart';
import 'package:leavelist/core/services/local_storage_service.dart';
import 'package:leavelist/features/home/models/checklist_item.dart';

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
}

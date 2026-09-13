// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CheckListAdapter extends TypeAdapter<CheckList> {
  @override
  final int typeId = 3;

  @override
  CheckList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CheckList(
      addrId: fields[0] as String,
      checklist: (fields[1] as List).cast<ChecklistItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, CheckList obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.addrId)
      ..writeByte(1)
      ..write(obj.checklist);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChecklistItemAdapter extends TypeAdapter<ChecklistItem> {
  @override
  final int typeId = 4;

  @override
  ChecklistItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChecklistItem(
      id: fields[0] as String,
      label: fields[1] as String,
      type: fields[2] as ItemType,
    );
  }

  @override
  void write(BinaryWriter writer, ChecklistItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChecklistItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemTypeAdapter extends TypeAdapter<ItemType> {
  @override
  final int typeId = 2;

  @override
  ItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemType.laptop;
      case 1:
        return ItemType.bag;
      case 2:
        return ItemType.idCard;
      case 3:
        return ItemType.outfit;
      case 4:
        return ItemType.bottle;
      case 5:
        return ItemType.keys;
      case 6:
        return ItemType.umbrella;
      case 7:
        return ItemType.headphone;
      default:
        return ItemType.laptop;
    }
  }

  @override
  void write(BinaryWriter writer, ItemType obj) {
    switch (obj) {
      case ItemType.laptop:
        writer.writeByte(0);
        break;
      case ItemType.bag:
        writer.writeByte(1);
        break;
      case ItemType.idCard:
        writer.writeByte(2);
        break;
      case ItemType.outfit:
        writer.writeByte(3);
        break;
      case ItemType.bottle:
        writer.writeByte(4);
        break;
      case ItemType.keys:
        writer.writeByte(5);
        break;
      case ItemType.umbrella:
        writer.writeByte(6);
        break;
      case ItemType.headphone:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_todo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyTodoModelAdapter extends TypeAdapter<DailyTodoModel> {
  @override
  final int typeId = 5;

  @override
  DailyTodoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyTodoModel(
      addressId: fields[0] as String,
      date: fields[1] as String,
      items: (fields[2] as List).cast<ChecklistItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, DailyTodoModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.addressId)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyTodoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

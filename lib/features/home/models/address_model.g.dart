// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddressModelAdapter extends TypeAdapter<AddressModel> {
  @override
  final int typeId = 1;

  @override
  AddressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddressModel(
      id: fields[0] as String,
      label: fields[1] as String,
      type: fields[2] as AddressType,
      lat: fields[3] as String,
      long: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AddressModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.lat)
      ..writeByte(4)
      ..write(obj.long);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AddressTypeAdapter extends TypeAdapter<AddressType> {
  @override
  final int typeId = 0;

  @override
  AddressType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AddressType.home;
      case 1:
        return AddressType.office;
      case 2:
        return AddressType.other;
      default:
        return AddressType.home;
    }
  }

  @override
  void write(BinaryWriter writer, AddressType obj) {
    switch (obj) {
      case AddressType.home:
        writer.writeByte(0);
        break;
      case AddressType.office:
        writer.writeByte(1);
        break;
      case AddressType.other:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

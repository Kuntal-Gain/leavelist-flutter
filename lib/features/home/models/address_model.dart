import 'package:hive/hive.dart';

part 'address_model.g.dart';

@HiveType(typeId: 0)
enum AddressType {
  @HiveField(0)
  home,

  @HiveField(1)
  office,

  @HiveField(2)
  other,
}

@HiveType(typeId: 1)
class AddressModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String label;

  @HiveField(2)
  final AddressType type;

  @HiveField(3)
  final String lat;

  @HiveField(4)
  final String long;

  const AddressModel({
    required this.id,
    required this.label,
    required this.type,
    required this.lat,
    required this.long,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'type': type.name,
      'lat': lat,
      'long': long,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      label: json['label'] as String,
      type: AddressType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      lat: json['lat'] as String,
      long: json['long'] as String,
    );
  }
}
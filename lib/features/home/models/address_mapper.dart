import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leavelist/features/home/models/address_model.dart';
import 'package:leavelist/features/home/models/map_pin.dart';

/// Converts between [MapPin] (map/UI concerns: marker icon, LatLng) and
/// [AddressModel] (the persisted shape) so the two layers can stay decoupled.
extension MapPinMapper on MapPin {
  AddressModel toAddressModel() {
    return AddressModel(
      id: id,
      label: title,
      type: category.toAddressType(),
      lat: position.latitude.toString(),
      long: position.longitude.toString(),
    );
  }
}

extension AddressModelMapper on AddressModel {
  MapPin toMapPin() {
    final category = type.toPinCategory();
    return MapPin(
      id: id,
      title: label,
      position: LatLng(double.parse(lat), double.parse(long)),
      icon: category.icon,
      category: category,
    );
  }
}

extension PinCategoryMapper on PinCategory {
  AddressType toAddressType() {
    switch (this) {
      case PinCategory.home:
        return AddressType.home;
      case PinCategory.work:
        return AddressType.office;
      case PinCategory.others:
        return AddressType.other;
    }
  }
}

extension AddressTypeMapper on AddressType {
  PinCategory toPinCategory() {
    switch (this) {
      case AddressType.home:
        return PinCategory.home;
      case AddressType.office:
        return PinCategory.work;
      case AddressType.other:
        return PinCategory.others;
    }
  }
}

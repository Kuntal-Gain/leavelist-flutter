import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:leavelist/core/exports/app_exports.dart';

enum PinCategory {
  home(label: 'Home', icon: AppIcons.home),
  work(label: 'Work', icon: HugeIconsSolid.work),
  others(label: 'Others', icon: AppIcons.location);

  const PinCategory({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class MapPin {
  final String id;
  final String title;
  final LatLng position;
  final IconData icon;
  final PinCategory category;

  const MapPin({
    required this.id,
    required this.title,
    required this.position,
    required this.icon,
    this.category = PinCategory.others,
  });
}

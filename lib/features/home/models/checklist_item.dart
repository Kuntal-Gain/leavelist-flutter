import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hugeicons_pro/hugeicons.dart';

part 'checklist_item.g.dart';

@HiveType(typeId: 2)
enum ItemType {
  @HiveField(0)
  laptop(
    label: 'Laptop',
    icon: HugeIconsSolid.laptop,
    color: Color(0xFF5B8DEF),
  ),

  @HiveField(1)
  bag(
    label: 'Bag',
    icon: HugeIconsSolid.handBag01,
    color: Color(0xFFB08968),
  ),

  @HiveField(2)
  idCard(
    label: 'ID Card',
    icon: HugeIconsSolid.identityCard,
    color: Color(0xFFEF8354),
  ),

  @HiveField(3)
  outfit(
    label: 'Outfit',
    icon: HugeIconsSolid.shirt01,
    color: Color(0xFFB185DB),
  ),

  @HiveField(4)
  bottle(
    label: 'Bottle',
    icon: HugeIconsSolid.rainDrop,
    color: Color(0xFF4FB0C6),
  ),

  @HiveField(5)
  keys(
    label: 'Keys',
    icon: HugeIconsSolid.lockKey,
    color: Color(0xFFE3B23C),
  ),

  @HiveField(6)
  umbrella(
    label: 'Umbrella',
    icon: HugeIconsSolid.umbrella,
    color: Color(0xFF57B894),
  ),

  @HiveField(7)
  headphone(
    label: 'Headphone',
    icon: HugeIconsSolid.headphones,
    color: Color(0xFFE0607E),
  );

  const ItemType({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

@HiveType(typeId: 3)
class CheckList {
  @HiveField(0)
  final String addrId;

  @HiveField(1)
  final List<ChecklistItem> checklist;

  const CheckList({
    required this.addrId,
    required this.checklist,
  });
}

@HiveType(typeId: 4)
class ChecklistItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String label;

  @HiveField(2)
  final ItemType type;

  const ChecklistItem({
    required this.id,
    required this.label,
    required this.type,
  });
}
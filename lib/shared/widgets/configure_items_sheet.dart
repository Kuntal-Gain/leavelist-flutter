import 'package:flutter/material.dart';
import 'package:leavelist/core/exports/app_exports.dart';
import 'package:leavelist/features/home/models/checklist_item.dart';
import 'package:leavelist/shared/buttons/app_btn.dart';

import 'bottom_sheet.dart';

/// Bottom sheet to build/edit the checklist of items to carry for an address.
///
/// Shows via [ConfigureItemsSheet.show], prefilled with [initialItems].
class ConfigureItemsSheet extends StatefulWidget {
  const ConfigureItemsSheet({super.key, required this.initialItems});

  final List<ChecklistItem> initialItems;

  static Future<List<ChecklistItem>?> show({
    required BuildContext context,
    List<ChecklistItem> initialItems = const [],
  }) {
    return AppBottomSheet.show<List<ChecklistItem>>(
      context: context,
      title: 'Configure items',
      subtitle: 'Add the things you need to carry for this address',
      showCloseButton: true,
      child: ConfigureItemsSheet(initialItems: initialItems),
    );
  }

  @override
  State<ConfigureItemsSheet> createState() => _ConfigureItemsSheetState();
}

class _ConfigureItemsSheetState extends State<ConfigureItemsSheet> {
  static const _fieldRadius = 10.0;

  late final TextEditingController _labelController;
  late ItemType _type;
  late final List<ChecklistItem> _items;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    _type = ItemType.laptop;
    _items = List.of(widget.initialItems);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  InputDecoration get _compactDecoration => InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.surfaceAlt,
        hintStyle: AppTypography.bodySmall,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.mp, vertical: AppSizes.s10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.4), width: 1),
        ),
      );

  void _onAddItem() {
    final label = _labelController.text.trim();
    if (label.isEmpty) return;

    setState(() {
      _items.add(
        ChecklistItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          label: label,
          type: _type,
        ),
      );
      _labelController.clear();
    });
  }

  void _onRemoveItem(ChecklistItem item) {
    setState(() => _items.removeWhere((i) => i.id == item.id));
  }

  void _onSave() {
    Navigator.of(context).pop(_items);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _labelController,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                decoration: _compactDecoration.copyWith(hintText: 'Item name'),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onAddItem(),
              ),
            ),
            SizedBox(width: AppSizes.s8),
            Expanded(
              flex: 2,
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<ItemType>(
                  initialValue: _type,
                  isExpanded: true,
                  isDense: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, size: AppSizes.s18, color: AppColors.textTertiary),
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                  decoration: _compactDecoration,
                  items: [
                    for (final type in ItemType.values)
                      DropdownMenuItem(
                        value: type,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(type.icon, size: AppSizes.s16, color: type.color),
                            SizedBox(width: AppSizes.s6),
                            Flexible(
                              child: Text(
                                type.label,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySmall.copyWith(color: type.color, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _type = value);
                  },
                ),
              ),
            ),
            SizedBox(width: AppSizes.s8),
            _AddButton(onTap: _onAddItem),
          ],
        ),
        SizedBox(height: AppSizes.mp),
        if (_items.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.xlp),
            child: Center(
              child: Text('No items added yet', style: AppTypography.bodySmall),
            ),
          )
        else
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _items.length,
              separatorBuilder: (_, __) => Divider(height: AppSizes.s1, thickness: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.s8),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSizes.s6),
                        decoration: BoxDecoration(
                          color: item.type.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.type.icon, size: AppSizes.s14, color: item.type.color),
                      ),
                      SizedBox(width: AppSizes.s10),
                      Expanded(
                        child: Text(
                          item.label,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _onRemoveItem(item),
                        behavior: HitTestBehavior.opaque,
                        child: Icon(Icons.close_rounded, size: AppSizes.s16, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        SizedBox(height: AppSizes.mp),
        AppButton(text: 'Save', onPressed: _onSave),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(_ConfigureItemsSheetState._fieldRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_ConfigureItemsSheetState._fieldRadius),
        child: SizedBox(
          width: AppSizes.s32,
          height: AppSizes.s32,
          child: Icon(Icons.add_rounded, size: AppSizes.s18, color: AppColors.white),
        ),
      ),
    );
  }
}

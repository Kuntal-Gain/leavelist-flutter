import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leavelist/core/exports/app_exports.dart';
import 'package:leavelist/features/home/models/map_pin.dart';
import 'package:leavelist/shared/buttons/app_btn.dart';

import 'bottom_sheet.dart';

class ConfigureLocationResult {
  const ConfigureLocationResult({required this.position, required this.category});

  final LatLng position;
  final PinCategory category;
}

/// Bottom sheet form to review/edit a lat-lng and assign it a category.
///
/// Shows via [ConfigureLocationSheet.show], prefilled with [initialPosition].
class ConfigureLocationSheet extends StatefulWidget {
  const ConfigureLocationSheet({super.key, required this.initialPosition, this.initialCategory});

  final LatLng initialPosition;
  final PinCategory? initialCategory;

  static Future<ConfigureLocationResult?> show({
    required BuildContext context,
    required LatLng initialPosition,
    PinCategory? initialCategory,
  }) {
    return AppBottomSheet.show<ConfigureLocationResult>(
      context: context,
      title: 'Add location',
      subtitle: 'Confirm coordinates and choose a category',
      showCloseButton: true,
      child: ConfigureLocationSheet(
        initialPosition: initialPosition,
        initialCategory: initialCategory,
      ),
    );
  }

  @override
  State<ConfigureLocationSheet> createState() => _ConfigureLocationSheetState();
}

class _ConfigureLocationSheetState extends State<ConfigureLocationSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late PinCategory _category;

  @override
  void initState() {
    super.initState();
    _latController = TextEditingController(text: widget.initialPosition.latitude.toStringAsFixed(6));
    _lngController = TextEditingController(text: widget.initialPosition.longitude.toStringAsFixed(6));
    _category = widget.initialCategory ?? PinCategory.home;
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  String? Function(String?) _validateCoordinate({required double min, required double max}) {
    return (value) {
      if (value == null || value.trim().isEmpty) return 'Required';
      final parsed = double.tryParse(value);
      if (parsed == null) return 'Enter a valid number';
      if (parsed < min || parsed > max) return 'Out of range';
      return null;
    };
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final result = ConfigureLocationResult(
      position: LatLng(double.parse(_latController.text), double.parse(_lngController.text)),
      category: _category,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latController,
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  validator: _validateCoordinate(min: -90, max: 90),
                ),
              ),
              SizedBox(width: AppSizes.mp),
              Expanded(
                child: TextFormField(
                  controller: _lngController,
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))],
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  validator: _validateCoordinate(min: -180, max: 180),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.xlp),
          Text('Category', style: AppTypography.labelLarge),
          SizedBox(height: AppSizes.s8),
          DropdownButtonFormField<PinCategory>(
            initialValue: _category,
            decoration: const InputDecoration(),
            items: [
              for (final category in PinCategory.values)
                DropdownMenuItem(
                  value: category,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(category.icon, size: AppSizes.s18, color: AppColors.primary),
                      SizedBox(width: AppSizes.s8),
                      Text(category.label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
                    ],
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _category = value);
            },
          ),
          SizedBox(height: AppSizes.xlp),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Cancel',
                  color: AppColors.surfaceAlt,
                  textColor: AppColors.textPrimary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              SizedBox(width: AppSizes.mp),
              Expanded(
                child: AppButton(text: 'Save', onPressed: _onSave),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

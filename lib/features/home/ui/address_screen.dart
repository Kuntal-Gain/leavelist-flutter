import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leavelist/core/exports/app_exports.dart';
import 'package:leavelist/features/home/models/map_pin.dart';
import 'package:leavelist/features/home/provider/home_provider.dart';
import 'package:leavelist/features/home/provider/todo_provider.dart';
import 'package:leavelist/shared/widgets/configure_items_sheet.dart';

class AddressScreen extends ConsumerWidget {
  const AddressScreen({super.key, this.onAddAddress});

  final VoidCallback? onAddAddress;

  Future<void> _onConfigureItems(
    BuildContext context,
    WidgetRef ref,
    MapPin pin,
  ) async {
    final initialItems = ref.read(todoProvider).itemsFor(pin.id);
    final result = await ConfigureItemsSheet.show(
      context: context,
      initialItems: initialItems,
    );
    if (result == null) return;

    await ref.read(todoProvider.notifier).setChecklistItems(pin.id, result);
  }

  void _onRemove(WidgetRef ref, MapPin pin) {
    ref.read(homeProvider.notifier).removePin(pin.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pins = ref.watch(homeProvider.select((s) => s.pins));

    if (pins.isEmpty) {
      return _EmptyAddressState(onAddAddress: onAddAddress);
    }

    return ListView.separated(
      padding: EdgeInsets.all(context.w(AppSizes.xlp)),
      itemCount: pins.length,
      separatorBuilder: (_, __) => context.sizeV(AppSizes.mp),
      itemBuilder: (context, index) {
        final pin = pins[index];
        return _AddressTile(
          pin: pin,
          onConfigureItems: () => _onConfigureItems(context, ref, pin),
          onRemove: () => _onRemove(ref, pin),
        );
      },
    );
  }
}

class _EmptyAddressState extends StatelessWidget {
  const _EmptyAddressState({this.onAddAddress});

  final VoidCallback? onAddAddress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(AppSizes.xlp),
          vertical: AppSizes.xlp,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.s20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.locationOutline,
                size: AppSizes.s32,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppSizes.xlp),
            Text('No addresses yet', style: AppTypography.titleMedium),
            SizedBox(height: AppSizes.s8),
            Text(
              "Let's add the places you don't want to\nforget your things at.",
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSizes.xlp),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GuideStep(
                    number: 1,
                    text: 'Go to the Home tab to open the map',
                  ),
                  _GuideStep(
                    number: 2,
                    text: 'Move the map to your location and tap "Add"',
                  ),
                  _GuideStep(
                    number: 3,
                    text: 'Pick a category and save — it shows up here',
                    isLast: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.xlp),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddAddress,
                icon: Icon(AppIcons.add, size: AppSizes.s18),
                label: Text(
                  'Add your first address',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppSizes.s12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.number,
    required this.text,
    this.isLast = false,
  });

  final int number;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.mp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSizes.s24,
            height: AppSizes.s24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: AppSizes.mp),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: AppSizes.s2),
              child: Text(text, style: AppTypography.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.pin,
    required this.onConfigureItems,
    required this.onRemove,
  });

  final MapPin pin;
  final VoidCallback onConfigureItems;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(AppSizes.xlp)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.r12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.s8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                ),
                child: Icon(
                  pin.category.icon,
                  size: AppSizes.s20,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: AppSizes.mp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pin.title, style: AppTypography.titleSmall),
                    SizedBox(height: AppSizes.s2),
                    Text(pin.category.label, style: AppTypography.labelMedium),
                    SizedBox(height: AppSizes.s4),
                    Text(
                      'Lat: ${pin.position.latitude.toStringAsFixed(6)}   '
                      'Lng: ${pin.position.longitude.toStringAsFixed(6)}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: EdgeInsets.all(AppSizes.s6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.delete,
                    size: AppSizes.s18,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.mp),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onConfigureItems,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: EdgeInsets.symmetric(vertical: AppSizes.s10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                ),
              ),
              child: Text(
                'Configure Items',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

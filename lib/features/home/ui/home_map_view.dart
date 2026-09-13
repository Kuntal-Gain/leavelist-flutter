import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leavelist/core/exports/app_exports.dart';
import 'package:leavelist/core/utils/widget_to_bitmap.dart';
import 'package:leavelist/features/home/models/map_pin.dart';
import 'package:leavelist/features/home/provider/home_provider.dart';
import 'package:leavelist/features/home/provider/todo_provider.dart';
import 'package:leavelist/shared/widgets/map_pin_widget.dart';

import '../../../shared/widgets/configure_location_sheet.dart';

const _initialCameraPosition = LatLng(22.5726, 88.3639);

class HomeMapView extends ConsumerStatefulWidget {
  const HomeMapView({super.key});

  @override
  ConsumerState<HomeMapView> createState() => _HomeMapViewState();
}

class _HomeMapViewState extends ConsumerState<HomeMapView> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng _currentCameraPosition = _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _buildMarkers());
  }

  Future<void> _buildMarkers() async {
    final homeState = ref.read(homeProvider);
    final markers = <Marker>{};

    for (final pin in homeState.pins) {
      final isSelected = pin.id == homeState.selectedPinId;
      final icon = await WidgetToBitmap.convert(
        context,
        MapPinWidget(icon: pin.icon, isSelected: isSelected),
        logicalSize: const Size(56, 68),
      );

      markers.add(
        Marker(
          markerId: MarkerId(pin.id),
          position: pin.position,
          icon: icon,
          anchor: const Offset(0.5, 1),
          consumeTapEvents: true,
          onTap: () {
            ref.read(homeProvider.notifier).selectPin(pin.id);
            _buildMarkers();
          },
        ),
      );
    }

    if (!mounted) return;
    setState(() => _markers
      ..clear()
      ..addAll(markers));
  }


  Future<void> _onAddPressed() async {
    final result = await ConfigureLocationSheet.show(
      context: context,
      initialPosition: _currentCameraPosition,
    );
    if (result == null) return;

    ref.read(homeProvider.notifier).addPin(
      MapPin(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: result.category.label,
        position: result.position,
        icon: result.category.icon,
        category: result.category,
      ),
    );
    await _buildMarkers();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(homeProvider.select((s) => s.pins), (_, __) => _buildMarkers());

    final selectedPinId = ref.watch(homeProvider.select((s) => s.selectedPinId));
    final pins = ref.watch(homeProvider.select((s) => s.pins));
    MapPin? selectedPin;
    for (final p in pins) {
      if (p.id == selectedPinId) {
        selectedPin = p;
        break;
      }
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddPressed,
        icon: Icon(AppIcons.add),
        label: Text("Add"),
        elevation: 0,

      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialCameraPosition,
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) => _currentCameraPosition = position.target,
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          if (selectedPin != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 68,
              child: _SelectedAddressPanel(
                key: ValueKey(selectedPin.id),
                pin: selectedPin,
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectedAddressPanel extends ConsumerStatefulWidget {
  const _SelectedAddressPanel({super.key, required this.pin});

  final MapPin pin;

  @override
  ConsumerState<_SelectedAddressPanel> createState() => _SelectedAddressPanelState();
}

class _SelectedAddressPanelState extends ConsumerState<_SelectedAddressPanel> {
  final Set<String> _checkedIds = {};

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(todoProvider).itemsFor(widget.pin.id);
    final checkedCount = items.where((item) => _checkedIds.contains(item.id)).length;
    final allChecked = items.isNotEmpty && checkedCount == items.length;
    final progress = items.isEmpty ? 0.0 : checkedCount / items.length;

    return Container(
      margin: EdgeInsets.fromLTRB(AppSizes.xlp, 0, AppSizes.xlp, AppSizes.xlp),
      constraints: BoxConstraints(maxHeight: context.heightWithFraction(0.55)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.r16 + AppSizes.s8),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: AppSizes.mp),
              width: AppSizes.s32,
              height: AppSizes.s4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppSizes.r4),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSizes.xlp,
              AppSizes.xlp,
              AppSizes.xlp,
              AppSizes.mp,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(AppSizes.s12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                  ),
                  child: Icon(widget.pin.category.icon, size: AppSizes.s24, color: AppColors.primary),
                ),
                SizedBox(width: AppSizes.mp + AppSizes.s4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.pin.title, style: AppTypography.titleMedium),
                      SizedBox(height: AppSizes.s4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: AppSizes.s8, vertical: AppSizes.s2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppSizes.r4),
                        ),
                        child: Text(
                          widget.pin.category.label,
                          style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                        ),
                      ),
                      SizedBox(height: AppSizes.s8),
                      Row(
                        children: [
                          Icon(Icons.my_location, size: AppSizes.s14, color: AppColors.textTertiary),
                          SizedBox(width: AppSizes.s4),
                          Expanded(
                            child: Text(
                              '${widget.pin.position.latitude.toStringAsFixed(6)}, '
                              '${widget.pin.position.longitude.toStringAsFixed(6)}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (items.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(left: AppSizes.mp),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: AppTypography.labelLarge.copyWith(
                        color: allChecked ? AppColors.success : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                      child: Text('$checkedCount/${items.length}'),
                    ),
                  ),
              ],
            ),
          ),
          if (items.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.xlp),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.r4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: AppSizes.s6,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation(
                      allChecked ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(height: AppSizes.mp),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.xlp),
            child: Divider(color: AppColors.divider, height: 1),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween(begin: 0.92, end: 1.0).animate(animation),
                child: SizeTransition(
                  sizeFactor: animation,
                  child: child,
                ),
              ),
            ),
            child: items.isEmpty
                ? Padding(
                    key: const ValueKey('empty'),
                    padding: EdgeInsets.all(AppSizes.xlp),
                    child: Text(
                      'No checklist items yet for this address.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  )
                : allChecked
                    ? Padding(
                        key: const ValueKey('done'),
                        padding: EdgeInsets.all(AppSizes.xlp),
                        child: const _AllDoneCard(),
                      )
                    : Flexible(
                        key: const ValueKey('list'),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(horizontal: AppSizes.xlp, vertical: AppSizes.mp),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => Divider(color: AppColors.divider, height: AppSizes.xlp),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final checked = _checkedIds.contains(item.id);
                            return InkWell(
                              borderRadius: BorderRadius.circular(AppSizes.r8),
                              onTap: () => setState(() {
                                if (checked) {
                                  _checkedIds.remove(item.id);
                                } else {
                                  _checkedIds.add(item.id);
                                }
                              }),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(AppSizes.s8),
                                    decoration: BoxDecoration(
                                      color: item.type.color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(AppSizes.r8),
                                    ),
                                    child: Icon(item.type.icon, size: AppSizes.s18, color: item.type.color),
                                  ),
                                  SizedBox(width: AppSizes.mp + AppSizes.s4),
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: checked ? AppColors.textTertiary : AppColors.textPrimary,
                                        decoration: checked ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppSizes.mp),
                                  Checkbox(
                                    value: checked,
                                    onChanged: (value) => setState(() {
                                      if (value ?? false) {
                                        _checkedIds.add(item.id);
                                      } else {
                                        _checkedIds.remove(item.id);
                                      }
                                    }),
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppSizes.r4),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
          SizedBox(height: AppSizes.mp),
        ],
      ),
    );
  }
}

class _AllDoneCard extends StatefulWidget {
  const _AllDoneCard();

  @override
  State<_AllDoneCard> createState() => _AllDoneCardState();
}

class _AllDoneCardState extends State<_AllDoneCard> with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final Animation<double> _iconScale;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _iconScale = CurvedAnimation(
      parent: _entryController,
      curve: Curves.elasticOut,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseScale = Tween(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: AppSizes.xlp),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.r12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _iconScale,
            child: AnimatedBuilder(
              animation: _pulseScale,
              builder: (context, child) => Transform.scale(
                scale: _pulseScale.value,
                child: child,
              ),
              child: Icon(Icons.check_circle, size: AppSizes.s32, color: AppColors.primary),
            ),
          ),
          SizedBox(height: AppSizes.s8),
          FadeTransition(
            opacity: _entryController,
            child: Text(
              'You can go now, without worry',
              style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

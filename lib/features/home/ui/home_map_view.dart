import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leavelist/core/exports/app_exports.dart';
import 'package:leavelist/core/utils/widget_to_bitmap.dart';
import 'package:leavelist/features/home/models/map_pin.dart';
import 'package:leavelist/features/home/models/checklist_item.dart';
import 'package:leavelist/features/home/provider/daily_todo_provider.dart';
import 'package:leavelist/features/home/provider/home_provider.dart';
import 'package:leavelist/features/home/provider/todo_provider.dart';
import 'package:leavelist/shared/widgets/map_pin_widget.dart';

import '../../../shared/widgets/configure_location_sheet.dart';

// Fallback used only when the device location is unavailable.
const _fallbackCameraPosition = LatLng(22.5726, 88.3639);

/// Distance from a pin within which the user counts as "at" that address.
const _arrivalRadiusMeters = 1.0;

class HomeMapView extends ConsumerStatefulWidget {
  const HomeMapView({super.key});

  @override
  ConsumerState<HomeMapView> createState() => _HomeMapViewState();
}

class _HomeMapViewState extends ConsumerState<HomeMapView> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng _currentCameraPosition = _fallbackCameraPosition;

  StreamSubscription<Position>? _positionSub;
  Position? _lastPosition;

  /// Pins the user is currently within [_arrivalRadiusMeters] of.
  final Set<String> _insidePinIds = {};

  /// Pins whose daily todo has been requested from storage.
  final Set<String> _loadedPinIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _buildMarkers());
    _moveToCurrentLocation();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  /// Compares the user's position with every pin, reacting to entering or
  /// leaving the arrival radius.
  void _evaluateProximity() {
    final position = _lastPosition;
    if (position == null || !mounted) return;

    final pins = ref.read(homeProvider).pins;
    final home = ref.read(homeProvider.notifier);

    var changed = false;

    for (final pin in pins) {
      // Today's items are needed for every pin so the warning can list them.
      if (_loadedPinIds.add(pin.id)) {
        ref.read(dailyTodoProvider.notifier).load(pin.id);
      }

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        pin.position.latitude,
        pin.position.longitude,
      );
      debugPrint('[HomeMap] ${pin.title}: ${distance.toStringAsFixed(1)} m away');
      final inside = distance <= _arrivalRadiusMeters;
      final wasInside = _insidePinIds.contains(pin.id);

      if (inside && !wasInside) {
        _insidePinIds.add(pin.id);
        home.selectPin(pin.id);
        changed = true;
      } else if (!inside && wasInside) {
        _insidePinIds.remove(pin.id);
        changed = true;

        // Close the panel: either everything is checked (nothing to show) or
        // the "you forgot your things" warning takes its place.
        if (ref.read(homeProvider).selectedPinId == pin.id) {
          home.selectPin(null);
        }
      }
    }

    if (changed) {
      setState(() {});
      _buildMarkers();
    }
  }

  /// Re-reads today's items and the current position, then re-checks
  /// proximity. Backs the warning's Refresh button.
  Future<void> _refresh() async {
    try {
      _lastPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint('[HomeMap] refresh failed to get position: $e');
    }
    _loadedPinIds.clear();
    _evaluateProximity();
    if (mounted) setState(() {});
  }

  Future<void> _moveToCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final target = LatLng(position.latitude, position.longitude);
      _currentCameraPosition = target;
      _lastPosition = position;
      if (!mounted) return;
      debugPrint('[HomeMap] initial position ${position.latitude}, ${position.longitude}');
      _evaluateProximity();

      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen((position) {
        _lastPosition = position;
        _evaluateProximity();
      });

      await _mapController?.animateCamera(CameraUpdate.newLatLng(target));
    } catch (e) {
      // Keep the fallback position if location can't be determined.
      debugPrint('[HomeMap] location setup failed: $e');
    }
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
    ref.listen(homeProvider.select((s) => s.pins), (_, __) {
      _buildMarkers();
      _evaluateProximity();
    });

    final selectedPinId = ref.watch(homeProvider.select((s) => s.selectedPinId));
    final pins = ref.watch(homeProvider.select((s) => s.pins));
    MapPin? selectedPin;
    for (final p in pins) {
      if (p.id == selectedPinId) {
        selectedPin = p;
        break;
      }
    }

    // A tapped pin wins; otherwise the panel opens by itself for a pin the
    // user is standing at, whether or not they tapped anything.
    MapPin? panelPin = selectedPin;
    if (panelPin == null) {
      for (final p in pins) {
        if (_insidePinIds.contains(p.id)) {
          panelPin = p;
          break;
        }
      }
    }

    // Nothing configured for this address: don't show the panel at all.
    final todos = ref.watch(todoProvider);
    final hasChecklist =
        panelPin != null && todos.itemsFor(panelPin.id).isNotEmpty;

    // Unchecked items of addresses the user walked away from.
    final dailyTodos = ref.watch(dailyTodoProvider);
    final forgottenItems = <ChecklistItem>[
      if (_lastPosition != null)
        for (final p in pins)
          if (!_insidePinIds.contains(p.id))
            ...dailyTodos.itemsFor(p.id).where((item) => !item.isDone),
    ];

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
              target: _currentCameraPosition,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              controller.animateCamera(CameraUpdate.newLatLng(_currentCameraPosition));
            },
            myLocationEnabled: true,
            onCameraMove: (position) => _currentCameraPosition = position.target,
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          if (panelPin != null && hasChecklist)
            Positioned(
              left: 0,
              right: 0,
              bottom: 68,
              child: _SelectedAddressPanel(
                key: ValueKey(panelPin.id),
                pin: panelPin,
              ),
            )
          else if (forgottenItems.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 68,
              child: _ForgotItemsWarning(
                items: forgottenItems,
                onRefresh: _refresh,
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dailyTodoProvider.notifier).load(widget.pin.id));
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(dailyTodoProvider).itemsFor(widget.pin.id);
    final checkedCount = items.where((item) => item.isDone).length;
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
                    : ListView.separated(
                        key: const ValueKey('list'),
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(horizontal: AppSizes.xlp, vertical: AppSizes.mp),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => Divider(color: AppColors.divider, height: AppSizes.xlp),
                        itemBuilder: (context, index) {
                            final item = items[index];
                            final checked = item.isDone;
                            void toggle() => ref
                                .read(dailyTodoProvider.notifier)
                                .toggleItem(widget.pin.id, item.id);
                            return InkWell(
                              borderRadius: BorderRadius.circular(AppSizes.r8),
                              onTap: toggle,
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
                                    onChanged: (_) => toggle(),
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
          SizedBox(height: AppSizes.mp),
        ],
      ),
    );
  }
}

/// Shown while the user is away from an address with unchecked items.
/// Item icons sit as overlapping translucent tiles when several things were
/// forgotten.
class _ForgotItemsWarning extends StatefulWidget {
  const _ForgotItemsWarning({required this.items, required this.onRefresh});

  final List<ChecklistItem> items;
  final Future<void> Function() onRefresh;

  @override
  State<_ForgotItemsWarning> createState() => _ForgotItemsWarningState();
}

class _ForgotItemsWarningState extends State<_ForgotItemsWarning> {
  bool _refreshing = false;
  double _turns = 0;

  Future<void> _handleRefresh() async {
    if (_refreshing) return;
    setState(() {
      _refreshing = true;
      _turns += 1;
    });
    await widget.onRefresh();
    if (mounted) setState(() => _refreshing = false);
  }

  /// "Laptop", "Laptop and Keys", "Laptop, Keys and Bag".
  String _namesOf(List<ChecklistItem> items) {
    final names = items.map((i) => i.label).toSet().toList();
    if (names.length <= 1) return names.join();
    return '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
  }

  static const _maxStacked = 4;
  static const _tileSize = 64.0;
  static const _step = _tileSize * 0.58;

  // Alternating tilt and lift so the tiles fan out like a hand of cards.
  static const _tilts = [-0.10, 0.06, -0.04, 0.09, -0.07];

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final shown = items.take(_maxStacked).toList();
    final extra = items.length - shown.length;
    final tileCount = shown.length + (extra > 0 ? 1 : 0);
    final stackWidth = _step * (tileCount - 1) + _tileSize;

    return Container(
      margin: EdgeInsets.fromLTRB(AppSizes.xlp, 0, AppSizes.xlp, AppSizes.xlp),
      padding: EdgeInsets.all(AppSizes.xlp),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.r16 + AppSizes.s8),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: AppSizes.mp),
          SizedBox(
            height: _tileSize + 12,
            width: stackWidth,
            child: Stack(
              children: [
                for (var i = 0; i < shown.length; i++)
                  Positioned(
                    left: i * _step,
                    top: i.isEven ? 0 : 10,
                    child: _tile(
                      tilt: _tilts[i],
                      color: shown[i].type.color,
                      child: Icon(shown[i].type.icon, size: 30, color: AppColors.white),
                    ),
                  ),
                if (extra > 0)
                  Positioned(
                    left: shown.length * _step,
                    top: shown.length.isEven ? 0 : 10,
                    child: _tile(
                      tilt: _tilts[shown.length % _tilts.length],
                      color: AppColors.textTertiary,
                      child: Text(
                        '+$extra',
                        style: AppTypography.titleMedium.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.xlp),
          Text(
            'Wait, you forgot something!',
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: AppSizes.s8),
          Text(
            '${_namesOf(items)} ${items.length == 1 ? 'is' : 'are'} still '
            'not checked. Please go back and bring '
            '${items.length == 1 ? 'it' : 'them'} with you.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSizes.xlp + AppSizes.s4),
          _refreshButton(),
        ],
      ),
    );
  }

  /// Flat orange CTA; the icon spins while the check runs.
  Widget _refreshButton() {
    return Material(
      color: AppColors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _refreshing ? null : _handleRefresh,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.mp + AppSizes.s4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedRotation(
                  turns: _turns,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  child: const Icon(Icons.refresh_rounded, size: 22, color: AppColors.white),
                ),
                SizedBox(width: AppSizes.s8),
                Text(
                  _refreshing ? 'Checking...' : "I've got them, check again",
                  style: AppTypography.button.copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// One card in the stack: solid colour, white rim and a shadow so each
  /// tile visibly sits above the previous one.
  Widget _tile({
    required Color color,
    required Widget child,
    required double tilt,
  }) {
    return Transform.rotate(
      angle: tilt,
      child: Container(
        width: _tileSize,
        height: _tileSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.75), color],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(-4, 6),
            ),
          ],
        ),
        child: child,
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

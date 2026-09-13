import 'package:leavelist/features/home/models/map_pin.dart';

class HomeState {
  final List<MapPin> pins;
  final String? selectedPinId;

  const HomeState({
    this.pins = const [],
    this.selectedPinId,
  });

  HomeState copyWith({
    List<MapPin>? pins,
    String? selectedPinId,
    bool clearSelectedPinId = false,
  }) {
    return HomeState(
      pins: pins ?? this.pins,
      selectedPinId: clearSelectedPinId ? null : (selectedPinId ?? this.selectedPinId),
    );
  }
}

import 'package:flutter/services.dart';

abstract interface class HapticService {
  Future<void> tilePickup();

  Future<void> acceptedSwap();

  Future<void> levelComplete();
}

class FlutterHapticService implements HapticService {
  @override
  Future<void> tilePickup() => HapticFeedback.selectionClick();

  @override
  Future<void> acceptedSwap() => HapticFeedback.lightImpact();

  @override
  Future<void> levelComplete() => HapticFeedback.mediumImpact();
}

import '../config/feature_flags.dart';

class AppAnalytics {
  final FeatureFlagsService _flags;
  AppAnalytics(this._flags);

  bool get enabled => _flags.isEnabled('analytics');

  Future<void> logEvent(String name, {Map<String, Object?> parameters = const {}}) async {
    if (!enabled) return;
    // TODO: Integrate Firebase Analytics or other provider here
    // For now, a no-op stub
  }
}

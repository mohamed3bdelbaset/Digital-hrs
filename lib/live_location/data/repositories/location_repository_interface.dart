import 'package:cnattendance/live_location/data/models/location_policy_model.dart';
import 'package:cnattendance/live_location/data/models/location_response_model.dart';

abstract class LocationRepositoryInterface {
  /// Get tracking policy from backend.
  Future<LocationPolicyModel> getPolicy();

  /// Send employee's current location to backend.
  Future<LocationResponseModel> sendLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
    int? batteryLevel,
    required bool isMock,
    required DateTime recordedAt,
  });
}

import 'dart:convert';

import 'package:cnattendance/data/source/datastore/preferences.dart';
import 'package:cnattendance/data/source/network/connect.dart';
import 'package:cnattendance/utils/constant.dart';
import 'package:flutter/material.dart';

import '../models/location_policy_model.dart';
import '../models/location_response_model.dart';

class LocationRepository {
  final Preferences _preferences = Preferences();
  final Connect _connect = Connect();

  static const Duration _timeout = Duration(seconds: 30);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _preferences.getToken();

    if (token.isEmpty) {
      throw Exception('Authentication token is missing');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decodeResponse(String body) {
    final decoded = jsonDecode(body);

    if (decoded is! Map) {
      throw Exception('Invalid API response');
    }

    return Map<String, dynamic>.from(decoded);
  }

  String _getErrorMessage(
    Map<String, dynamic> response,
    String fallback,
  ) {
    return response['message']?.toString() ?? fallback;
  }

  // GET LOCATION POLICY
  Future<LocationPolicyModel> getPolicy() async {
    try {
      final headers = await _getHeaders();

      final response = await _connect
          .getResponse(
            Constant.LOCATION_POLICY_URL,
            headers,
          )
          .timeout(_timeout);

      debugPrint('Policy Status: ${response.statusCode}');

      debugPrint('Policy Response: ${response.body}');

      final responseData = _decodeResponse(response.body);

      if (response.statusCode == 200) {
        final data = responseData['data'] ?? responseData;

        return LocationPolicyModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw Exception(
        _getErrorMessage(
          responseData,
          'Failed to get location policy',
        ),
      );
    } catch (e) {
      debugPrint('getPolicy error $e');

      rethrow;
    }
  }

  // SEND LOCATION
  Future<LocationResponseModel> sendLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
    int? batteryLevel,
    required bool isMock,
    required DateTime recordedAt,
  }) async {
    if (!latitude.isFinite ||
        !longitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180 ||
        (latitude == 0 && longitude == 0)) {
      throw Exception('Invalid location coordinates');
    }

    try {
      final headers = await _getHeaders();

      final body = <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'is_mock': isMock,
        'recorded_at': recordedAt.toUtc().toIso8601String(),
        if (accuracy != null) 'accuracy': accuracy,
        if (batteryLevel != null) 'battery_level': batteryLevel,
      };

      final response = await _connect
          .postResponseRaw(
            Constant.SEND_LOCATION,
            headers,
            body,
          )
          .timeout(_timeout);

      debugPrint('Send Location Status: ${response.statusCode}');

      debugPrint('Send Location Response: ${response.body}');

      final responseData = _decodeResponse(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = responseData['data'] ?? responseData;

        return LocationResponseModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      throw Exception(
        _getErrorMessage(
          responseData,
          'Failed to send location',
        ),
      );
    } catch (e) {
      debugPrint('sendLocation error $e');

      rethrow;
    }
  }
}


import UIKit
import Flutter
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate {

    private let locationManager = CLLocationManager()

    private let locationMethodChannel =
        "com.cyclonenepal.digitalhrs/location"

    private let locationEventChannel =
        "com.cyclonenepal.digitalhrs/location_events"

    private var locationEventSink: FlutterEventSink?

    private var isTrackingEnabled = false

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
            [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)

        setupLocationManager()
        setupLocationChannels()

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }

    // MARK: - Location Manager

    private func setupLocationManager() {

        locationManager.delegate = self

        locationManager.desiredAccuracy =
            kCLLocationAccuracyBest

        locationManager.distanceFilter =
            kCLDistanceFilterNone

        locationManager.allowsBackgroundLocationUpdates =
            true

        locationManager.pausesLocationUpdatesAutomatically =
            false

        locationManager.activityType =
            .otherNavigation
    }

    // MARK: - Flutter Channels

    private func setupLocationChannels() {

        guard let controller =
            window?.rootViewController as? FlutterViewController
        else {
            return
        }

        let methodChannel = FlutterMethodChannel(
            name: locationMethodChannel,
            binaryMessenger: controller.binaryMessenger
        )

        methodChannel.setMethodCallHandler {
            [weak self] call, result in

            guard let self = self else {
                result(
                    FlutterError(
                        code: "LOCATION_ERROR",
                        message: "Location manager unavailable",
                        details: nil
                    )
                )
                return
            }

            switch call.method {

            case "requestPermission":
                self.requestLocationPermission(result: result)

            case "startTracking":
                self.startTracking(result: result)

            case "stopTracking":
                self.stopTracking()
                result(true)

            case "isTracking":
                result(self.isTrackingEnabled)

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        let eventChannel = FlutterEventChannel(
            name: locationEventChannel,
            binaryMessenger: controller.binaryMessenger
        )

        eventChannel.setStreamHandler(self)
    }

    // MARK: - Permissions

    private func requestLocationPermission(
        result: @escaping FlutterResult
    ) {

        let status = locationManager.authorizationStatus

        switch status {

        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            result("requesting")

        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            result("requesting")

        case .authorizedAlways:
            result("authorizedAlways")

        case .denied, .restricted:
            result("denied")

        @unknown default:
            result("unknown")
        }
    }

    // MARK: - Start Tracking

    private func startTracking(
        result: @escaping FlutterResult
    ) {

        guard CLLocationManager.locationServicesEnabled() else {
            result(
                FlutterError(
                    code: "LOCATION_DISABLED",
                    message: "Location services are disabled",
                    details: nil
                )
            )
            return
        }

        let status = locationManager.authorizationStatus

        guard status == .authorizedAlways else {
            result(
                FlutterError(
                    code: "PERMISSION_REQUIRED",
                    message: "Always location permission is required",
                    details: nil
                )
            )
            return
        }

        guard CLLocationManager
            .significantLocationChangeMonitoringAvailable()
        else {
            result(
                FlutterError(
                    code: "UNAVAILABLE",
                    message: "Location monitoring is unavailable",
                    details: nil
                )
            )
            return
        }

        isTrackingEnabled = true

        locationManager.startUpdatingLocation()

        locationManager.startMonitoringSignificantLocationChanges()

        result(true)
    }

    // MARK: - Stop Tracking

    private func stopTracking() {

        isTrackingEnabled = false

        locationManager.stopUpdatingLocation()

        locationManager.stopMonitoringSignificantLocationChanges()
    }

    // MARK: - Send Location to Flutter

    private func sendLocation(_ location: CLLocation) {

        guard isTrackingEnabled else {
            return
        }

        let data: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "accuracy": location.horizontalAccuracy,
            "altitude": location.altitude,
            "speed": location.speed,
            "heading": location.course,
            "recorded_at": ISO8601DateFormatter().string(
                from: location.timestamp
            )
        ]

        DispatchQueue.main.async {
            self.locationEventSink?(data)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension AppDelegate: CLLocationManagerDelegate {

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {

        guard let location = locations.last else {
            return
        }

        guard location.horizontalAccuracy >= 0 else {
            return
        }

        sendLocation(location)
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {

        print("LOCATION ERROR: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {

        print(
            "LOCATION AUTHORIZATION: \(manager.authorizationStatus.rawValue)"
        )
    }
}

// MARK: - Flutter Stream Handler

extension AppDelegate: FlutterStreamHandler {

    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {

        locationEventSink = events

        return nil
    }

    func onCancel(
        withArguments arguments: Any?
    ) -> FlutterError? {

        locationEventSink = nil

        return nil
    }
}

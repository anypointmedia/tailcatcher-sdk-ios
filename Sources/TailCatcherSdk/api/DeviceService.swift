import Foundation
import SwiftUI
import CoreLocation

class DeviceService: NSObject, CLLocationManagerDelegate {
    public static var instance: DeviceService!
    private var latitude: Double?
    private var longitude: Double?
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        requestLocation()
    }

    func getLocale() -> String? {
        Locale.preferredLanguages.first
    }

    func getLatitude() -> Double? {
        requestLocation()
        return latitude
    }

    func getLongitude() -> Double? {
        requestLocation()
        return longitude
    }

    func getDeviceType() -> String? {
        return if UIDevice().userInterfaceIdiom == .phone {
            "Mobile"
        } else if UIDevice().userInterfaceIdiom == .pad {
            "Tablet"
        } else if UIDevice().userInterfaceIdiom == .tv {
            "CTV"
        } else {
            nil
        }
    }

    func getDeviceModel() -> String {
        UIDevice().model
    }

    func getDeviceManufacturer() -> String {
        "Apple"
    }

    func getOs() -> String {
        UIDevice().systemName
    }

    func getOsVersion() -> String {
        UIDevice().systemVersion
    }

    func getAppPackage() -> String? {
        Bundle.main.bundleIdentifier
    }

    func getAppVersion() -> String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    private func requestLocation() {
        DispatchQueue.global().async { [locationManager] in
            guard CLLocationManager.locationServicesEnabled() else {
                return
            }

            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone

            let authorizationStatus = locationManager.authorizationStatus

            switch authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.requestLocation()
                break
            default:
                break
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
}

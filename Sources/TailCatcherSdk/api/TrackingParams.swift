import Foundation

class TrackingParams {
    public static var CUSTOMER = ""
    public static var RETAILER = ""

    public static var UID: String? = nil
    public static var PAGE: String? = nil
    public static var LAST_PAGE_VISITED: Date? = nil
    public static var PRODUCT: String? = nil

    private let action: String
    private let params: [String: String]
    private let pageRetentionTimeMs: Int?
    private let deviceService: DeviceService = DeviceService.instance

    init(action: String, params: [String: String] = [:], pageRetentionTimeMs: Int? = nil) {
        self.action = action
        self.params = params
        self.pageRetentionTimeMs = pageRetentionTimeMs
    }

    func toQueryParams() -> String {
        let urlParams = [
            "c": TrackingParams.CUSTOMER,
            "pd": TrackingParams.PRODUCT,
            "r": TrackingParams.RETAILER,
            "p": TrackingParams.PAGE,
            "prt": pageRetentionTimeMs.map { String($0) },
            "uid": TrackingParams.UID,
            "a": action,
            "d": nil,
            "l": deviceService.getLocale(),
            "lt": deviceService.getLatitude().map { String($0) },
            "ln": deviceService.getLongitude().map { String($0) },
            "dt": deviceService.getDeviceType(),
            "dm": deviceService.getDeviceModel(),
            "dmf": deviceService.getDeviceManufacturer(),
            "o": deviceService.getOs(),
            "ov": deviceService.getOsVersion(),
            "ap": deviceService.getAppPackage(),
            "av": deviceService.getAppVersion(),
            "ct": !params.isEmpty
                ? try? String(data: JSONSerialization.data(withJSONObject: params), encoding: String.Encoding.utf8)
                : nil
        ]

        return urlParams.map { (key, value) in
            key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! + "=" + (value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        }
        .joined(separator: "&")
    }
}

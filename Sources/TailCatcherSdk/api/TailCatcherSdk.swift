import Foundation
import SwiftUI

enum TailCatcherError: Error {
    case missingParam(String)
}

public class TailCatcherSdk {
    private static let TRACKING_HOST = "https://a-cdn.anypoint.tv/t"
    private static var session: URLSession!

    public static func doInit(appContext: Any, customer: String, retailer: String) {
        DeviceService.instance = DeviceService()

        loadCookies()
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = HTTPCookieStorage.shared
        session = URLSession(configuration: config)

        TrackingParams.CUSTOMER = customer
        TrackingParams.RETAILER = retailer
    }

    public static func setUser(user: String?) {
        if (TrackingParams.UID == user) {
            return
        }

        TrackingParams.UID = user

        if user != nil {
            try? logEvent(event: "login")
        } else {
            try? logEvent(event: "logout")
        }
    }

    public static func logEvent(event: String, params: [String: String]? = nil) throws {
        switch event {
        case EventName.VIEW_PAGE:
            try logViewPageEvent(params: params)
        case EventName.VIEW_ITEM:
            try logViewItemEvent(params: params)
        default:
            logParams(params: TrackingParams(action: event, params: params ?? [:]))
        }
    }

    private static func logParams(params: TrackingParams) {
        let url = URL(string: TRACKING_HOST + "?" + params.toQueryParams())!

        print("TailCatcher: \(url)")

        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else {
                saveCookies()
            }
        }
        .resume()
    }

    private static func logViewPageEvent(params: [String: String]?) throws {
        let event = EventName.VIEW_PAGE

        if (params == nil || params!["page"] == nil) {
            throw TailCatcherError.missingParam("params.page is required for event \(event)")
        }

        var pageRetentionTimeMs: Int? = nil

        if (TrackingParams.LAST_PAGE_VISITED != nil) {
            pageRetentionTimeMs = Int(Date().timeIntervalSince(TrackingParams.LAST_PAGE_VISITED!) * 1000)
        }

        TrackingParams.PAGE = params!["page"]
        TrackingParams.LAST_PAGE_VISITED = Date()
        TrackingParams.PRODUCT = nil

        logParams(
            params: TrackingParams(
                action: event,
                params: params!.filter { $0.key != "page" },
                pageRetentionTimeMs: pageRetentionTimeMs
            )
        )
    }

    private static func logViewItemEvent(params: [String: String]?) throws {
        let event = EventName.VIEW_ITEM

        if (params == nil || params!["product"] == nil) {
            throw TailCatcherError.missingParam("params.product is required for event \(event)")
        }

        TrackingParams.PRODUCT = params!["product"]

        logParams(
            params: TrackingParams(
                action: event,
                params: params!.filter { $0.key != "product" }
            )
        )
    }

    private static func saveCookies() {
        guard let cookies = HTTPCookieStorage.shared.cookies else { return }
        let cookiesData = cookies.compactMap { cookie in
            return try? NSKeyedArchiver.archivedData(withRootObject: cookie, requiringSecureCoding: false)
        }
        UserDefaults.standard.set(cookiesData, forKey: "savedCookies")
    }

    private static func loadCookies() {
        guard let cookiesData = UserDefaults.standard.array(forKey: "savedCookies") as? [Data] else { return }
        let cookies = cookiesData.compactMap { data in
            return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? HTTPCookie
        }
        let cookieStorage = HTTPCookieStorage.shared
        cookies.forEach { cookie in
            cookieStorage.setCookie(cookie)
        }
    }

    public struct EventName {
        public static let VIEW_PAGE = "view_page"
        public static let VIEW_ITEM = "view_item"
        public static let PURCHASE = "purchase"
    }
}

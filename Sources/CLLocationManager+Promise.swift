import CoreLocation.CLLocationManager
#if !PMKCOCOAPODS
import PromiseKit
#endif

#if !os(tvOS)

/**
 To import the `CLLocationManager` category:

    use_frameworks!
    pod "PromiseKit/CoreLocation"

 And then in your sources:

    import PromiseKit
*/
extension CLLocationManager {

    /// The location authorization type
    public enum RequestAuthorizationType {
        /// Determine the authorization from the application’s plist
        case automatic
        /// Request always-authorization
        case always
        /// Request when-in-use-authorization
        case whenInUse
    }

    /**
      - Returns: A new promise that fulfills with the most recent CLLocation.
      - Note: To return all locations call `allResults()`. 
      - Parameter requestAuthorizationType: We read your Info plist and try to
      determine the authorization type we should request automatically. If you
      want to force one or the other, change this parameter from its default
      value.
     */
    public class func requestLocation(authorizationType: RequestAuthorizationType = .automatic) -> Promise<[CLLocation]> {
        return promise(yielding: auther(authorizationType))
    }

    @available(*, deprecated: 5.0, renamed: "requestLocation")
    public class func promise(_ requestAuthorizationType: RequestAuthorizationType = .automatic) -> Promise<[CLLocation]> {
        return requestLocation(authorizationType: requestAuthorizationType)
    }

    private class func promise(yielding yield: (CLLocationManager) -> Void = { _ in }) -> Promise<[CLLocation]> {
        let manager = LocationManager()
        manager.delegate = manager
        yield(manager)
        manager.startUpdatingLocation()
        _ = manager.promise.ensure {
            manager.stopUpdatingLocation()
        }
        return manager.promise
    }
}

private class LocationManager: CLLocationManager, CLLocationManagerDelegate {
    let (promise, seal) = Promise<[CLLocation]>.pending()

    @objc fileprivate func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        seal.fulfill(locations)
    }

    @objc func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let (domain, code) = { ($0.domain, $0.code) }(error as NSError)
        if code == CLError.locationUnknown.rawValue && domain == kCLErrorDomain {
            // Apple docs say you should just ignore this error
        } else {
            seal.reject(error)
        }
    }
}


#if os(iOS) || os(watchOS)

extension CLLocationManager {
    /// request CoreLocation authorization from user
    @available(iOS 8, *)
    public class func requestAuthorization(type: RequestAuthorizationType = .automatic) -> Guarantee<CLAuthorizationStatus> {
        return AuthorizationCatcher(auther: auther(type), type: type).promise
    }
}

@available(iOS 8, *)
private class AuthorizationCatcher: CLLocationManager, CLLocationManagerDelegate {
    let (promise, fulfill) = Guarantee<CLAuthorizationStatus>.pending()
    var retainCycle: AuthorizationCatcher?

    init(auther: (CLLocationManager) -> Void, type: CLLocationManager.RequestAuthorizationType) {
        super.init()
        let status = CLLocationManager.authorizationStatus()
        switch (status, type) {
        case (.notDetermined, _), (.authorizedWhenInUse, .always), (.authorizedWhenInUse, .automatic):
            delegate = self
            auther(self)
            retainCycle = self
        default:
            fulfill(status)
        }
        promise.done { _ in
            self.retainCycle = nil
        }
    }

    @objc fileprivate func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .notDetermined {
            fulfill(status)
        }
    }
}

private func auther(_ requestAuthorizationType: CLLocationManager.RequestAuthorizationType) -> ((CLLocationManager) -> Void) {

    //PMKiOS7 guard #available(iOS 8, *) else { return }
    return { manager in
        func hasInfoPlistKey(_ key: String) -> Bool {
            let value = Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
            return !value.isEmpty
        }

        switch requestAuthorizationType {
        case .automatic:
            let always = hasInfoPlistKey("NSLocationAlwaysUsageDescription") || hasInfoPlistKey("NSLocationAlwaysAndWhenInUsageDescription")
            let whenInUse = { hasInfoPlistKey("NSLocationWhenInUseUsageDescription") }
            if always {
                manager.requestAlwaysAuthorization()
            } else {
                if !whenInUse() { NSLog("PromiseKit: Warning: `NSLocationWhenInUseUsageDescription` key not set") }
                manager.requestWhenInUseAuthorization()
            }
        case .whenInUse:
            manager.requestWhenInUseAuthorization()
            break
        case .always:
            manager.requestAlwaysAuthorization()
            break

        }
    }
}

#else

private func auther(_ requestAuthorizationType: CLLocationManager.RequestAuthorizationType) -> (CLLocationManager) -> Void {
    return { _ in }
}

#endif

#endif

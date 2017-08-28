import PMKCoreLocation
import CoreLocation
import PromiseKit
import XCTest

class CLGeocoderTests: XCTestCase {
    func test_reverseGeocodeLocation() {
        class MockGeocoder: CLGeocoder {
            override func reverseGeocodeLocation(_ location: CLLocation, completionHandler: @escaping CLGeocodeCompletionHandler) {
                after(.seconds(0)).done {
                    completionHandler([dummyPlacemark], nil)
                }
            }
        }

        let ex = expectation(description: "")
        MockGeocoder().reverseGeocode(location: CLLocation()).done { x in
            XCTAssertEqual(x, [dummyPlacemark])
            ex.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func test_geocodeAddressDictionary() {
        class MockGeocoder: CLGeocoder {
            override func geocodeAddressDictionary(_ addressDictionary: [AnyHashable : Any], completionHandler: @escaping CLGeocodeCompletionHandler) {
                after(.seconds(0)).done {
                    completionHandler([dummyPlacemark], nil)
                }
            }
        }

        let ex = expectation(description: "")
        MockGeocoder().geocode([:]).done { x in
            XCTAssertEqual(x, [dummyPlacemark])
            ex.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func test_geocodeAddressString() {
        class MockGeocoder: CLGeocoder {
            override func geocodeAddressString(_ addressString: String, completionHandler: @escaping CLGeocodeCompletionHandler) {
                after(.seconds(0)).done {
                    completionHandler([dummyPlacemark], nil)
                }
            }
        }

        let ex = expectation(description: "")
        MockGeocoder().geocode("").done { x in
            XCTAssertEqual(x, [dummyPlacemark])
            ex.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}

private let dummyPlacemark = CLPlacemark()

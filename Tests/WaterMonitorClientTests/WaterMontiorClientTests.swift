import XCTest
import class Foundation.Bundle
@testable import WaterMonitorClient

final class WaterMonitorClientTests: XCTestCase {
    
    let client = WaterMonitorClient(urlString: "") //Put your endpoint url here.
    
    func testGetReadings() throws {

        let completedExpectation = expectation(description: "Completed")
        
        client.fetchLatestReadings { result in
            print(result)
            completedExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)

    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
}

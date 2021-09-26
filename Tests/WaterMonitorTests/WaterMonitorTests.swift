import XCTest
import class Foundation.Bundle
@testable import AWSLambdaEvents
@testable import AWSLambdaRuntime
@testable import AWSLambdaTesting
//@testable import WaterMonitorClient

final class WaterMonitorTests: XCTestCase {
    
    func testGetReadings() throws {
        
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

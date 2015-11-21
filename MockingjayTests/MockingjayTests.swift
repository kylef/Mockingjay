//
//  MockingjayTests.swift
//  MockingjayTests
//
//  Created by Kyle Fuller on 21/01/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation
import XCTest
import Mockingjay

func toString(item:AnyClass) -> String {
  return "\(item)"
}

class MockingjaySessionTests: XCTestCase {
  override func setUp() {
    super.setUp()
    NSURLSessionConfiguration.mockingjaySwizzleDefaultSessionConfiguration()
  }

  func testEphemeralSessionConfigurationIncludesProtocol() {
    let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    let protocolClasses = (configuration.protocolClasses!).map(toString)
    XCTAssertEqual(protocolClasses.first!, "MockingjayProtocol")
  }

  func testDefaultSessionConfigurationIncludesProtocol() {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    let protocolClasses = (configuration.protocolClasses!).map(toString)
    XCTAssertEqual(protocolClasses.first!, "MockingjayProtocol")
  }

  func testURLSession() {
    let expectation = expectationWithDescription("MockingjaySessionTests")

    let stubbedError = NSError(domain: "Mockingjay Session Tests", code: 0, userInfo: nil)
    stub(everything, builder: failure(stubbedError))

    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: configuration)

    session.dataTaskWithURL(NSURL(string: "https://httpbin.org/")!) { data, response, error in
      dispatch_async(dispatch_get_main_queue()) {
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.domain, "Mockingjay Session Tests")
        expectation.fulfill()
      }
    }.resume()

    waitForExpectationsWithTimeout(5) { error in
      XCTAssertNil(error, "\(error)")
    }
  }
}

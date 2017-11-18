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

func toString(_ item:AnyClass) -> String {
  return "\(item)"
}

class MockingjaySessionTests: XCTestCase {
  override func setUp() {
    super.setUp()
  }

  func testEphemeralSessionConfigurationIncludesProtocol() {
    let configuration = URLSessionConfiguration.ephemeral
    let protocolClasses = (configuration.protocolClasses!).map(toString)
    XCTAssertEqual(protocolClasses.first!, "MockingjayProtocol")
  }

  func testDefaultSessionConfigurationIncludesProtocol() {
    let configuration = URLSessionConfiguration.default
    let protocolClasses = (configuration.protocolClasses!).map(toString)
    XCTAssertEqual(protocolClasses.first!, "MockingjayProtocol")
  }

  func testURLSession() {
    let expectation = self.expectation(description: "MockingjaySessionTests")

    let stubbedError = NSError(domain: "Mockingjay Session Tests", code: 0, userInfo: nil)
    stub(everything, failure(stubbedError))

    let configuration = URLSessionConfiguration.default
    let session = URLSession(configuration: configuration)

    session.dataTask(with: URL(string: "https://httpbin.org/")!, completionHandler: { data, response, error in
      DispatchQueue.main.async {
        XCTAssertNotNil(error)
        XCTAssertEqual((error as NSError?)?.domain, "Mockingjay Session Tests")
        expectation.fulfill()
      }
    }) .resume()

    waitForExpectations(timeout: 5) { error in
      XCTAssertNil(error, String(describing: error))
    }
  }
}

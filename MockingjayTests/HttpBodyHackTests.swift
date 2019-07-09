//
//  HttpBodyHackTests.swift
//  Mockingjay
//
//  Created by Alexey Kozhevnikov on 05/12/2016.
//  Copyright © 2016 Cocode. All rights reserved.
//

import Foundation
import XCTest
@testable import Mockingjay

class HttpBodyHackTests: XCTestCase {
  var urlSession:URLSession!
  
  override func setUp() {
    super.setUp()
    urlSession = URLSession(configuration: URLSessionConfiguration.default)
  }
  
  override func tearDown() {
    urlSession = nil
    super.tearDown()
  }

  func test() {
    let data = "some data".data(using: .utf8)
    
    let bodyHack = HttpBodyHack()
    let matcher: Matcher = { request in
      XCTAssertEqual(bodyHack.body(request), data)
      return true
    }
    stub(matcher, http())
    
    let expectation = self.expectation(description: "completion called")
    var request = URLRequest(url: URL(string: "https://kylefuller.co.uk/")!)
    request.httpBody = data
    let dataTask = urlSession.dataTask(with: request) { _ in
      expectation.fulfill()
    }
    dataTask.resume()
    
    waitForExpectations(timeout: 2.0, handler: nil)
  }
}

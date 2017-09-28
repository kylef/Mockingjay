//
//  MockingjayURLProtocolTests.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 28/02/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation
import XCTest
import Mockingjay


class MockingjayProtocolTests : XCTestCase {
  
  var urlSession:URLSession!
  
  override func setUp() {
    super.setUp()
    urlSession = URLSession(configuration: URLSessionConfiguration.default)
  }
  
  override func tearDown() {
    super.tearDown()
    MockingjayProtocol.removeAllStubs()
  }

  func testCannotInitWithUnknownRequest() {
    let request = URLRequest(url: URL(string: "https://kylefuller.co.uk/")!)
    let canInitWithRequest = MockingjayProtocol.canInit(with: request)

    XCTAssertFalse(canInitWithRequest)
  }

  func testCanInitWithKnownRequestUsingMatcher() {
    let request = URLRequest(url: URL(string: "https://kylefuller.co.uk/")!)

    MockingjayProtocol.addStub(matcher: { (requestedRequest) -> (Bool) in
      return true
    }) { (request) -> (Response) in
      return Response.failure(NSError(domain: "MockingjayTests", code: 0, userInfo: nil))
    }

    let canInitWithRequest = MockingjayProtocol.canInit(with: request)

    XCTAssertTrue(canInitWithRequest)
  }

  func testProtocolReturnsErrorWithRegisteredStubError() {
    let request = URLRequest(url: URL(string: "https://kylefuller.co.uk/")!)
    let stubError = NSError(domain: "MockingjayTests", code: 0, userInfo: nil)

    MockingjayProtocol.addStub(matcher: { _ in
      return true
    }) { (request) -> (Response) in
      return Response.failure(stubError)
    }

    var response: URLResponse?
    var error:Error?
    var data: Data? = nil
    
    let expectation = self.expectation(description: "testProtocolReturnsErrorWithRegisteredStubError")
    let dataTask = urlSession.dataTask(with: request) { (d, r, e) in
      response = r
      data = d
      error = e
      expectation.fulfill()
    }
    dataTask.resume()
    waitForExpectations(timeout: 2.0, handler: nil)
    
    XCTAssertNil(response)
    XCTAssertNil(data)
    XCTAssertNotNil(error)
  }

  func testProtocolReturnsResponseWithRegisteredStubError() {
    let request = URLRequest(url: URL(string: "https://kylefuller.co.uk/")!)
    let stubResponse = URLResponse(url: request.url!, mimeType: "text/plain", expectedContentLength: 5, textEncodingName: "utf-8")
    let stubData = "Hello".data(using: String.Encoding.utf8, allowLossyConversion: true)!

    MockingjayProtocol.addStub(matcher: { (requestedRequest) -> (Bool) in
      return true
    }) { (request) -> (Response) in
        return Response.success(stubResponse, .content(stubData))
    }
    
    var response:URLResponse?
    var data:Data?
    var error:Error?

    let expectation = self.expectation(description: "testProtocolReturnsResponseWithRegisteredStubError")
    let dataTask = urlSession.dataTask(with: request) { (d, r, e) in
      response = r
      data = d
      error = e
      expectation.fulfill()
    }
    dataTask.resume()
    waitForExpectations(timeout: 2.0, handler: nil)

    XCTAssertEqual(response?.url, stubResponse.url!)
    XCTAssertEqual(response?.textEncodingName, "utf-8")
    XCTAssertEqual(data, stubData)
    XCTAssertNil(error)
  }

  func testProtocolReturnsResponseWithLastRegisteredMatchingStub() {
    let request = URLRequest(url: URL(string: "https://fuller.li/")!)
    let stubResponse = URLResponse(url: request.url!, mimeType: "text/plain", expectedContentLength: 6, textEncodingName: "utf-8")
    let stub1Data = "Stub 1".data(using: String.Encoding.utf8, allowLossyConversion: true)!
    let stub2Data = "Stub 2".data(using: String.Encoding.utf8, allowLossyConversion: true)!

    MockingjayProtocol.addStub(matcher: { (requestedRequest) -> (Bool) in
      return true
    }) { (request) -> (Response) in
        return Response.success(stubResponse, .content(stub1Data))
    }

    MockingjayProtocol.addStub(matcher: { (requestedRequest) -> (Bool) in
      return true
    }) { (request) -> (Response) in
        return Response.success(stubResponse, .content(stub2Data))
    }

    var response:URLResponse?
    var data:Data?
    var error:Error?
    
    let expectation = self.expectation(description: "testProtocolReturnsResponseWithRegisteredStubError")
    let dataTask = urlSession.dataTask(with: request) { (d, r, e) in
      response = r
      data = d
      error = e
      expectation.fulfill()
    }
    dataTask.resume()
    waitForExpectations(timeout: 2.0, handler: nil)

    XCTAssertEqual(response?.url, stubResponse.url!)
    XCTAssertEqual(response?.textEncodingName, "utf-8")
    XCTAssertEqual(data, stub2Data)
    XCTAssertNil(error)
  }
  
  func testDelay() {
    let request = URLRequest(url: URL(string: "https://kylefuller.co.uk/")!)
    
    MockingjayProtocol.addStub(matcher: { (requestedRequest) -> (Bool) in
      return true
    }, delay: 1) { (request) -> (Response) in
      let response = URLResponse(url: request.url!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
      return Response.success(response, .noContent)
    }
    
    let expectation = self.expectation(description: "testDelay")
    let dataTask = urlSession.dataTask(with: request) { _,_,_  in
      expectation.fulfill()
    }
    
    let startDate = Date()
    dataTask.resume()
    waitForExpectations(timeout: 2.0, handler: nil)
    
    XCTAssert(startDate.addingTimeInterval(0.95).compare(Date()) == .orderedAscending)
  }
  
}

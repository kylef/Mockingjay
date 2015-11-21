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
  override func tearDown() {
    super.tearDown()
    MockingjayProtocol.removeAllStubs()
  }

  func testCannotInitWithUnknownRequest() {
    let request = NSURLRequest(URL: NSURL(string: "https://kylefuller.co.uk/")!)
    let canInitWithRequest = MockingjayProtocol.canInitWithRequest(request)

    XCTAssertFalse(canInitWithRequest)
  }

  func testCanInitWithKnownRequestUsingMatcher() {
    let request = NSURLRequest(URL: NSURL(string: "https://kylefuller.co.uk/")!)

    MockingjayProtocol.addStub({ (requestedRequest) -> (Bool) in
      return true
    }) { (request) -> (Response) in
      return Response.Failure(NSError(domain: "MockingjayTests", code: 0, userInfo: nil))
    }

    let canInitWithRequest = MockingjayProtocol.canInitWithRequest(request)

    XCTAssertTrue(canInitWithRequest)
  }

  func testProtocolReturnsErrorWithRegisteredStubError() {
    let request = NSURLRequest(URL: NSURL(string: "https://kylefuller.co.uk/")!)
    let stubError = NSError(domain: "MockingjayTests", code: 0, userInfo: nil)

    MockingjayProtocol.addStub({ (requestedRequest) -> (Bool) in
      return true
    }) { (request) -> (Response) in
      return Response.Failure(stubError)
    }

    var response:NSURLResponse?
    var error:NSError?
    var data: NSData? = nil
    do {
      data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
    } catch let error1 as NSError {
      error = error1
    }

    XCTAssertNil(response)
    XCTAssertNil(data)
    XCTAssertEqual(error!.domain, "MockingjayTests")  }

  func testProtocolReturnsResponseWithRegisteredStubError() {
    let request = NSURLRequest(URL: NSURL(string: "https://kylefuller.co.uk/")!)
    let stubResponse = NSURLResponse(URL: request.URL!, MIMEType: "text/plain", expectedContentLength: 5, textEncodingName: "utf-8")
    let stubData = "Hello".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!

    MockingjayProtocol.addStub({ (requestedRequest) -> (Bool) in
      return true
    }) { (request) -> (Response) in
      return Response.Success(stubResponse, stubData)
    }

    var response:NSURLResponse?
    let data = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)

    XCTAssertEqual(response?.URL, stubResponse.URL!)
    XCTAssertEqual(response?.textEncodingName, "utf-8")
    XCTAssertEqual(data, stubData)
  }
}

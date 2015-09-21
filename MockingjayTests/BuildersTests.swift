//
//  BuildersTests.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 01/03/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation
import XCTest
import Mockingjay


class FailureBuilderTests : XCTestCase {
  func testFailure() {
    let request = NSURLRequest(URL: NSURL(string: "http://test.com/")!)
    let error = NSError(domain: "MockingjayTests", code: 0, userInfo: nil)

    let response = failure(error)(request:request)

    XCTAssertEqual(response, Response.Failure(error))
  }

  func testHTTP() {
    let request = NSURLRequest(URL: NSURL(string: "http://test.com/")!)

    let response = http()(request: request)

    switch response {
    case let .Success(response, _):
      if let response = response as? NSHTTPURLResponse {
        XCTAssertEqual(response.statusCode, 200)
      } else {
        XCTFail("Test Failure")
      }
      break
    default:
      XCTFail("Test Failure")
    }
  }

  func testJSON() {
    let request = NSURLRequest(URL: NSURL(string: "http://test.com/")!)

    let response = json(["A"])(request: request)

    switch response {
    case let .Success(response, data):
      if let response = response as? NSHTTPURLResponse {
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.MIMEType!, "application/json")
        XCTAssertEqual(response.textEncodingName!, "utf-8")
        let body = NSString(data:data!, encoding:NSUTF8StringEncoding) as! String
        XCTAssertEqual(body, "[\"A\"]")
      } else {
        XCTFail("Test Failure")
      }
      break
    default:
      XCTFail("Test Failure")
    }
  }

  func testJSONData() {
    let request = NSURLRequest(URL: NSURL(string: "http://test.com")!)

    let data = "[\"B\"]".dataUsingEncoding(NSUTF8StringEncoding)!

    let response = jsonData(data)(request: request)

    switch response {
    case let .Success(response, data):
      if let response = response as? NSHTTPURLResponse {
        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.MIMEType!, "application/json")
        XCTAssertEqual(response.textEncodingName!, "utf-8")
        let body = NSString(data:data!, encoding:NSUTF8StringEncoding) as! String
        XCTAssertEqual(body, "[\"B\"]")
      } else {
        XCTFail("Test Failure")
      }
      break
    default:
      XCTFail("Test Failure")
    }
  }
}

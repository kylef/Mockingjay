//
//  MatcherTests.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 28/02/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation
import XCTest
import Mockingjay


class EverythingMatcherTests : XCTestCase {
  func testEverythingMatcher() {
    let request = URLRequest(url: URL(string: "https://api.palaverapp.com/")!)
    XCTAssertTrue(everything(request))
  }
}

class URIMatcherTests : XCTestCase {
  func testExactFullURIMatches() {
    let request = URLRequest(url: URL(string: "https://api.palaverapp.com/")!)
    XCTAssertTrue(uri("https://api.palaverapp.com/")(request))
  }

  func testExactFullPathMatches() {
    let request = URLRequest(url: URL(string: "https://api.palaverapp.com/devices")!)
    XCTAssertTrue(uri("/devices")(request))
  }

  func testExactFullURIMismatch() {
    let request = URLRequest(url: URL(string: "https://api.palaverapp.com/devices")!)
    XCTAssertFalse(uri("https://api.palaverapp.com/notifications")(request))
  }

  func testExactFullPathMismatch() {
    let request = URLRequest(url: URL(string: "https://api.palaverapp.com/devices")!)
    XCTAssertFalse(uri("/notifications")(request))
  }

  func testVariableFullURIMatch() {
    let request = URLRequest(url: URL(string: "https://github.com/kylef/URITemplate")!)
    XCTAssertTrue(uri("https://github.com/{username}/URITemplate")(request))
  }

  func testVariablePathMatch() {
    let request = URLRequest(url: URL(string: "https://github.com/kylef/URITemplate")!)
    XCTAssertTrue(uri("/{username}/URITemplate")(request))
  }
}

class HTTPMatcherTests : XCTestCase {
  func testMethodURIMatch() {
    var request = URLRequest(url: URL(string: "https://api.palaverapp.com/")!)
    request.httpMethod = "PATCH"

    XCTAssertTrue(http(.patch, uri: "https://api.palaverapp.com/")(request))
  }
  
  func testMethodBodyMatch() {
    let request = NSMutableURLRequest(URL: NSURL(string: "https://api.palaverapp.com/")!)
    let body = NSData(base64EncodedString: "ABCD", options: NSDataBase64DecodingOptions())
    request.HTTPMethod = "PATCH"
    request.HTTPBody = body
    
    XCTAssertTrue(http(.PATCH, uri: "https://api.palaverapp.com/", body:body!)(request:request))
  }

  func testMethodMismatch() {
    var request = URLRequest(url: URL(string: "https://api.palaverapp.com/")!)
    request.httpMethod = "GET"

    XCTAssertFalse(http(.patch, uri: "https://api.palaverapp.com/")(request))
  }
  
  func testMethodBodyMissMatch() {
    let request = NSMutableURLRequest(URL: NSURL(string: "https://api.palaverapp.com/")!)
    let body = NSData(base64EncodedString: "ABCD", options: NSDataBase64DecodingOptions())
    let bodyMisMatch = NSData(base64EncodedString: "EFGH", options: NSDataBase64DecodingOptions())
    request.HTTPMethod = "PATCH"
    request.HTTPBody = body
    
    XCTAssertFalse(http(.PATCH, uri: "https://api.palaverapp.com/", body:bodyMisMatch!)(request:request))
  }
}

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
    let request = NSURLRequest()
    XCTAssertTrue(everything(request))
  }
}

class URIMatcherTests : XCTestCase {
  func testExactFullURIMatches() {
    let request = NSURLRequest(URL: NSURL(string: "https://api.palaverapp.com/")!)
    XCTAssertTrue(uri("https://api.palaverapp.com/")(request:request))
  }

  func testExactFullPathMatches() {
    let request = NSURLRequest(URL: NSURL(string: "https://api.palaverapp.com/devices")!)
    XCTAssertTrue(uri("/devices")(request:request))
  }

  func testExactFullURIMismatch() {
    let request = NSURLRequest(URL: NSURL(string: "https://api.palaverapp.com/devices")!)
    XCTAssertFalse(uri("https://api.palaverapp.com/notifications")(request:request))
  }

  func testExactFullPathMismatch() {
    let request = NSURLRequest(URL: NSURL(string: "https://api.palaverapp.com/devices")!)
    XCTAssertFalse(uri("/notifications")(request:request))
  }

  func testVariableFullURIMatch() {
    let request = NSURLRequest(URL: NSURL(string: "https://github.com/kylef/URITemplate")!)
    XCTAssertTrue(uri("https://github.com/{username}/URITemplate")(request:request))
  }

  func testVariablePathMatch() {
    let request = NSURLRequest(URL: NSURL(string: "https://github.com/kylef/URITemplate")!)
    XCTAssertTrue(uri("/{username}/URITemplate")(request:request))
  }
}

class HTTPMatcherTests : XCTestCase {
  func testMethodURIMatch() {
    let request = NSMutableURLRequest(URL: NSURL(string: "https://api.palaverapp.com/")!)
    request.HTTPMethod = "PATCH"

    XCTAssertTrue(http(.PATCH, uri: "https://api.palaverapp.com/")(request:request))
  }

  func testMethodMismatch() {
    let request = NSMutableURLRequest(URL: NSURL(string: "https://api.palaverapp.com/")!)
    request.HTTPMethod = "GET"

    XCTAssertFalse(http(.PATCH, uri: "https://api.palaverapp.com/")(request:request))
  }
}

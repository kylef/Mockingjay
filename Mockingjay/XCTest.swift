//
//  XCTest.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 28/02/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation
import XCTest

var mockingjayTearDownSwizzleToken: dispatch_once_t = 0

extension XCTest {
  // MARK: Stubbing

  public func stub(matcher:Matcher, builder:Builder) -> Stub {
    XCTest.mockingjaySwizzleTearDown()
    NSURLSessionConfiguration.mockingjaySwizzleDefaultSessionConfiguration()

    return MockingjayProtocol.addStub(matcher, builder: builder)
  }

  public func removeStub(stub:Stub) {
    MockingjayProtocol.removeStub(stub)
  }

  public func removeAllStubs() {
    MockingjayProtocol.removeAllStubs()
  }

  // MARK: Teardown

  public class func mockingjaySwizzleTearDown() {
    dispatch_once(&mockingjayTearDownSwizzleToken) {
      let tearDown = class_getInstanceMethod(self, "tearDown")
      let mockingjayTearDown = class_getInstanceMethod(self, "mockingjayTearDown")
      method_exchangeImplementations(tearDown, mockingjayTearDown)
    }
  }

  func mockingjayTearDown() {
    mockingjayTearDown()
    MockingjayProtocol.removeAllStubs()
  }
}
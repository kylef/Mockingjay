//
//  XCTest.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 28/02/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation
import XCTest

extension XCTest {
  // MARK: Stubbing

  public func stub(matcher:Matcher, builder:Builder) -> Stub {
    return MockingjayProtocol.addStub(matcher, builder: builder)
  }

  public func removeStub(stub:Stub) {
    MockingjayProtocol.removeStub(stub)
  }

  public func removeAllStubs() {
    MockingjayProtocol.removeAllStubs()
  }

  // MARK: Teardown

  override public class func initialize() {
    if (self === XCTest.self) {
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

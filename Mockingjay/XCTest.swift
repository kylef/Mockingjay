//
//  XCTest.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 28/02/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import ObjectiveC
import XCTest

var mockingjayTearDownSwizzleToken: dispatch_once_t = 0

var AssociatedMockingjayRemoveStubOnTearDownHandle: UInt8 = 0
extension XCTest {
  // MARK: Stubbing

  /// Whether Mockingjay should remove stubs on teardown
  public var mockingjayRemoveStubOnTearDown: Bool {
    get {
      let associatedResult = objc_getAssociatedObject(self, &AssociatedMockingjayRemoveStubOnTearDownHandle) as? Bool
      return associatedResult ?? true
    }

    set {
      objc_setAssociatedObject(self, &AssociatedMockingjayRemoveStubOnTearDownHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  public func stub(matcher:Matcher, builder:Builder) -> Stub {
    if mockingjayRemoveStubOnTearDown {
      XCTest.mockingjaySwizzleTearDown()
    }

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
      let tearDown = class_getInstanceMethod(self, #selector(XCTest.tearDown))
      let mockingjayTearDown = class_getInstanceMethod(self, #selector(XCTest.mockingjayTearDown))
      method_exchangeImplementations(tearDown, mockingjayTearDown)
    }
  }

  func mockingjayTearDown() {
    mockingjayTearDown()

    if mockingjayRemoveStubOnTearDown {
      MockingjayProtocol.removeAllStubs()
    }
  }
}
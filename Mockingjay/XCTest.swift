//
//  XCTest.swift
//  Mockingjay
//
//  Copyright (c) 2015, Kyle Fuller
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  * Neither the name of Mockingjay nor the names of its
//  contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
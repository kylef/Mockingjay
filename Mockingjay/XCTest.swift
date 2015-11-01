//
//  XCTest.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 28/02/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import XCTest

extension XCTest {
  public func stub(matcher:Matcher, builder:Builder) -> Stub {
    return MockingjayProtocol.addStub(matcher, builder: builder)
  }

  public func removeStub(stub:Stub) {
    MockingjayProtocol.removeStub(stub)
  }

  public func removeAllStubs() {
    MockingjayProtocol.removeAllStubs()
  }
}

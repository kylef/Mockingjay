//
//  XCTest.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 28/02/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation
import XCTest
import Mockingjay

extension XCTest {
  // MARK: Stubbing

  func stub(matcher:Matcher, builder:Builder) -> Stub {
    return MockingjayProtocol.addStub(matcher, builder: builder)
  }

  func removeStub(stub:Stub) {
    MockingjayProtocol.removeStub(stub)
  }

  func removeAllStubs() {
    MockingjayProtocol.removeAllStubs()
  }
}

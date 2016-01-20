//
//  MockingjayXCTestTests.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 20/01/2016.
//  Copyright © 2016 Cocode. All rights reserved.
//

import XCTest
import Mockingjay


class MockingjayXCTestTests: XCTestCase {
  func testEnablesRemovingStubsByDefault() {
    XCTAssertTrue(mockingjayRemoveStubOnTearDown)
  }

  func testUserCanDisableRemovingStubst() {
    mockingjayRemoveStubOnTearDown = false
    XCTAssertFalse(mockingjayRemoveStubOnTearDown)
  }
}
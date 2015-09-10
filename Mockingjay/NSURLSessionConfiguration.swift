//
//  NSURLSessionConfiguration.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 01/03/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation

extension NSURLSessionConfiguration {
  override public class func initialize() {
    if (self === NSURLSessionConfiguration.self) {
      let defaultSessionConfiguration = class_getClassMethod(self, "defaultSessionConfiguration")
      let mockingjayDefaultSessionConfiguration = class_getClassMethod(self, "mockingjayDefaultSessionConfiguration")
      method_exchangeImplementations(defaultSessionConfiguration, mockingjayDefaultSessionConfiguration)

      let ephemeralSessionConfiguration = class_getClassMethod(self, "ephemeralSessionConfiguration")
      let mockingjayEphemeralSessionConfiguration = class_getClassMethod(self, "mockingjayEphemeralSessionConfiguration")
      method_exchangeImplementations(ephemeralSessionConfiguration, mockingjayEphemeralSessionConfiguration)
    }
  }

  class func mockingjayDefaultSessionConfiguration() -> NSURLSessionConfiguration {
    let configuration = mockingjayDefaultSessionConfiguration()
    configuration.protocolClasses = [MockingjayProtocol.self] as [AnyClass] + configuration.protocolClasses!
    return configuration
  }

  class func mockingjayEphemeralSessionConfiguration() -> NSURLSessionConfiguration {
    let configuration = mockingjayEphemeralSessionConfiguration()
    configuration.protocolClasses = [MockingjayProtocol.self] as [AnyClass] + configuration.protocolClasses!
    return configuration
  }
}

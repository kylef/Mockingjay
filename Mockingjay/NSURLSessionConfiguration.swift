//
//  NSURLSessionConfiguration.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 01/03/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation

var mockingjaySessionSwizzleToken: dispatch_once_t = 0

extension NSURLSessionConfiguration {
  /// Swizzles NSURLSessionConfiguration's default and ephermeral sessions to add Mockingjay
  public class func mockingjaySwizzleDefaultSessionConfiguration() {
    dispatch_once(&mockingjaySessionSwizzleToken) {
      let defaultSessionConfiguration = class_getClassMethod(self, #selector(NSURLSessionConfiguration.defaultSessionConfiguration))
      let mockingjayDefaultSessionConfiguration = class_getClassMethod(self, #selector(NSURLSessionConfiguration.mockingjayDefaultSessionConfiguration))
      method_exchangeImplementations(defaultSessionConfiguration, mockingjayDefaultSessionConfiguration)

      let ephemeralSessionConfiguration = class_getClassMethod(self, #selector(NSURLSessionConfiguration.ephemeralSessionConfiguration))
      let mockingjayEphemeralSessionConfiguration = class_getClassMethod(self, #selector(NSURLSessionConfiguration.mockingjayEphemeralSessionConfiguration))
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

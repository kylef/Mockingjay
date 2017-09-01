//
//  NSURLSessionConfiguration.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 01/03/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation

let swizzleDefaultSessionConfiguration: Void = {
  guard
    let defaultSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.default)),
    let mockingjayDefaultSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.mockingjayDefaultSessionConfiguration))
    else { return }
  method_exchangeImplementations(defaultSessionConfiguration, mockingjayDefaultSessionConfiguration)

  guard
    let ephemeralSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.ephemeral)),
    let mockingjayEphemeralSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.mockingjayEphemeralSessionConfiguration))
    else { return }
    method_exchangeImplementations(ephemeralSessionConfiguration, mockingjayEphemeralSessionConfiguration)
}()

extension URLSessionConfiguration {
  /// Swizzles NSURLSessionConfiguration's default and ephermeral sessions to add Mockingjay
  @objc public class func mockingjaySwizzleDefaultSessionConfiguration() {
    _ = swizzleDefaultSessionConfiguration
  }

  @objc class func mockingjayDefaultSessionConfiguration() -> URLSessionConfiguration {
    let configuration = mockingjayDefaultSessionConfiguration()
    configuration.protocolClasses = [MockingjayProtocol.self] as [AnyClass] + configuration.protocolClasses!
    return configuration
  }

  @objc class func mockingjayEphemeralSessionConfiguration() -> URLSessionConfiguration {
    let configuration = mockingjayEphemeralSessionConfiguration()
    configuration.protocolClasses = [MockingjayProtocol.self] as [AnyClass] + configuration.protocolClasses!
    return configuration
  }
}

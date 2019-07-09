//
//  HttpBodyHack.swift
//  Mockingjay
//
//  Created by Alexey Kozhevnikov on 05/12/2016.
//  Copyright © 2016 Cocode. All rights reserved.
//

import Foundation

/*
 * Use this hack to retrieve HTTP body from inside Mockingjay matcher. Now HTTP body is always nil due to Apple bug.
 * See https://github.com/kylef/Mockingjay/issues/32
 *
 * Usage:
 *
 * func test() {
 *     let hack = HttpBodyHack()
 *
 *     let matcher: Matcher = { request in
 *         let data = hack.body(request)
 *         // use data
 *     }
 *
 *     // make request
 *
 *     waitForExpectationsWithTimeout(1) { _ in }
 * }
 */

private let httpBodyHackHeaderName = "HTTPBodyHack"

private let httpBodyHackLock = NSLock()
private var httpBodyHackValues = [String: Data]()

extension URLRequest {
  fileprivate func httpBodyHack() -> Data? {
    if let key = allHTTPHeaderFields?[httpBodyHackHeaderName] {
      httpBodyHackLock.lock()
      defer {
        httpBodyHackLock.unlock()
      }
      return httpBodyHackValues[key]
    } else {
      return nil
    }
  }
}

extension NSMutableURLRequest {
  fileprivate class func httpBodyHackSwizzle() {
    let setHttpBody = class_getInstanceMethod(self, #selector(setter: NSMutableURLRequest.httpBody))
    let httpBodyHackSetHttpBody = class_getInstanceMethod(self, #selector(NSMutableURLRequest.httpBodyHackSetHttpBody(_:)))
    method_exchangeImplementations(setHttpBody, httpBodyHackSetHttpBody)
  }
  
  func httpBodyHackSetHttpBody(_ body: Data?) {
    // Don't allow stripping of request
    if body == nil {
      return
    }
    var headers = allHTTPHeaderFields ?? [:]
    let key = UUID().uuidString
    headers[httpBodyHackHeaderName] = key
    allHTTPHeaderFields = headers
    
    httpBodyHackLock.lock()
    defer {
      httpBodyHackLock.unlock()
    }
    httpBodyHackValues[key] = body
  }
}

public class HttpBodyHack {
  private static var instanceCount = 0
  private static let lock = NSLock()
  
  public init() {
    HttpBodyHack.lock.lock()
    defer {
      HttpBodyHack.lock.unlock()
    }
    if HttpBodyHack.instanceCount == 0 {
      NSMutableURLRequest.httpBodyHackSwizzle()
    }
    HttpBodyHack.instanceCount += 1
  }
  
  public func body(_ request: URLRequest) -> Data? {
    return request.httpBodyHack()
  }
  
  public func headers(_ request: URLRequest) -> [String: String]? {
    guard let headers = request.allHTTPHeaderFields else {
      return nil
    }
    var result = headers
    result.removeValue(forKey: httpBodyHackHeaderName)
    return result
  }

  deinit {
    HttpBodyHack.lock.lock()
    defer {
      HttpBodyHack.lock.unlock()
    }
    HttpBodyHack.instanceCount -= 1
    if HttpBodyHack.instanceCount == 0 {
      // Unswizzle
      NSMutableURLRequest.httpBodyHackSwizzle()
      
      httpBodyHackLock.lock()
      defer {
        httpBodyHackLock.unlock()
      }
      httpBodyHackValues.removeAll()
    }
  }
}

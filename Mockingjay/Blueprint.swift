//
//  XCTest.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 28/02/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Representor
import XCTest

/// Extension to XCTest for API Blueprint stubbing
extension XCTest {
  /*** Stub an entire API Blueprint
  :param: blueprint The given blueprint to stub
  :param: baseURL An optional base URI for the URL matching
  */
  public func stub(blueprint:Blueprint, baseURL:String?) {
    var relativeURL:NSURL?
    if let baseURL = baseURL {
      relativeURL = NSURL(string: baseURL)
    }

    let resources = reduce(map(blueprint.resourceGroups) { $0.resources }, [], +)

    for resource in resources {
      for action in resource.actions {
        let url = NSURL(string: action.uriTemplate ?? resource.uriTemplate, relativeToURL: relativeURL)

        func matcher(request:NSURLRequest) -> Bool {
          if let requestMethod = request.HTTPMethod {
            if requestMethod == action.method {
              return uri(url!.absoluteString!)(request: request)
            }
          }

          return false
        }

        if let example = action.examples.first {
          // Todo content-negotiate requests

          if let response = example.responses.first {
            // Headers in the HTTP method are wrong and are a dictionary :(
            let headers = reduce(response.headers, [String:String]()) { accumulator, header in
              var mutaleAccumulator = accumulator
              mutaleAccumulator[header.name] = header.value
              return mutaleAccumulator
            }

            if let status = response.name.toInt() {
              let builder = http(status:status, headers:headers, data:response.body)
              stub(matcher, builder)
            }
          }
        }
      }
    }
  }
}

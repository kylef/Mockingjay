//
//  BlueprintStub.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 01/03/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation

func matcher(resource:Resource, action:Action) -> Matcher {
  if let method = HTTPMethod(rawValue: action.method) {
    return http(method, resource.uriTemplate)
  }

  return { request in return false }
}

func builder(resource:Resource, action:Action) -> Builder {
  return http(status: action, headers: nil, data: nil)
}

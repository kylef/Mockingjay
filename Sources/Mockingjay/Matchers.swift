//
//  Matchers.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 28/02/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation
import URITemplate

// Collection of generic matchers

/// Mockingjay matcher which returns true for every request
public func everything(_ request: URLRequest) -> Bool {
  return true
}

/// Mockingjay matcher which matches URIs
public func uri(_ uri:String) -> (_ request: URLRequest) -> Bool {
  
  return { (request:URLRequest) in
    let template = URITemplate(template:uri)
    
    if let URLString = request.url?.absoluteString {
      if template.extract(URLString) != nil {
        return true
      }
    }
    
    if let path = request.url?.path {
      if template.extract(path) != nil {
        return true
      }
    }
    
    return false
  }
}

public enum HTTPMethod : CustomStringConvertible {
  case get
  case post
  case patch
  case put
  case delete
  case options
  case head

  public var description : String {
    switch self {
    case .get:
      return "GET"
    case .post:
      return "POST"
    case .patch:
      return "PATCH"
    case .put:
      return "PUT"
    case .delete:
      return "DELETE"
    case .options:
      return "OPTIONS"
    case .head:
      return "HEAD"
    }
  }
}

public func http(_ method: HTTPMethod, uri: String) -> (_ request: URLRequest) -> Bool {
  return { (request:URLRequest) in
    if let requestMethod = request.httpMethod {
      if requestMethod == method.description {
        return Mockingjay.uri(uri)(request)
      }
    }
    
    return false
  }
}

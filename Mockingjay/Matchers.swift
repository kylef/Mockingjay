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
public func everything(request:NSURLRequest) -> Bool {
  return true
}

/// Mockingjay matcher which matches URIs
public func uri(uri:String)(request:NSURLRequest) -> Bool {
  let template = URITemplate(template:uri)

  if let URLString = request.URL.absoluteString {
    if template.extract(URLString) != nil {
      return true
    }
  }

  if let path = request.URL.path {
    if template.extract(path) != nil {
      return true
    }
  }

  return false
}

public enum HTTPMethod: String {
  case OPTIONS = "OPTIONS"
  case GET = "GET"
  case HEAD = "HEAD"
  case POST = "POST"
  case PUT = "PUT"
  case PATCH = "PATCH"
  case DELETE = "DELETE"
  case TRACE = "TRACE"
  case CONNECT = "CONNECT"
}

public func http(method:HTTPMethod, uri:String)(request:NSURLRequest) -> Bool {
  if let requestMethod = request.HTTPMethod {
    if requestMethod == method.rawValue {
      return Mockingjay.uri(uri)(request: request)
    }
  }

  return false
}

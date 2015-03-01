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

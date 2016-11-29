//
//  Matchers.swift
//  Mockingjay
//
//  Copyright (c) 2015, Kyle Fuller
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  * Neither the name of Mockingjay nor the names of its
//  contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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

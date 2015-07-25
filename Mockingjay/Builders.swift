//
//  Builders.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 01/03/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation

// Collection of generic builders

/// Generic builder for returning a failure
public func failure(error:NSError)(request:NSURLRequest) -> Response {
  return .Failure(error)
}

public func http(status:Int = 200, headers:[String:String]? = nil, data:NSData? = nil)(request:NSURLRequest) -> Response {
  if let response = NSHTTPURLResponse(URL: request.URL!, statusCode: status, HTTPVersion: nil, headerFields: headers) {
    return Response.Success(response, data)
  }

  return .Failure(NSError(domain: NSInternalInconsistencyException, code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to construct response for stub."]))
}

public func json(body:AnyObject, status:Int = 200, headers:[String:String]? = nil)(request:NSURLRequest) -> Response {
  var error:NSError?
  let data: NSData?
  do {
    data = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions())
  } catch var error1 as NSError {
    error = error1
    data = nil
  }

  if let data = data {
    var headers = headers ?? [String:String]()
    if headers["Content-Type"] == nil {
      headers["Content-Type"] = "application/json; charset=utf-8"
    }

    return http(status, headers: headers, data: data)(request:request)
  }

  return .Failure(error!)
}

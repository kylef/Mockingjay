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
func failure(error:NSError)(request:NSURLRequest) -> Response {
  return .Failure(error)
}

func http(status:Int = 200, headers:[String:String]? = nil, data:NSData? = nil)(request:NSURLRequest) -> Response {
  if let response = NSHTTPURLResponse(URL: request.URL!, statusCode: status, HTTPVersion: nil, headerFields: headers) {
    return Response.Success(response, data)
  }

  return .Failure(NSError(domain: NSInternalInconsistencyException, code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to construct response for stub."]))
}

func json(body:AnyObject, status:Int = 200, headers:[String:String]? = nil)(request:NSURLRequest) -> Response {
    do {
      let data = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions())
      return jsonData(data, status: status, headers: headers)(request: request)
    } catch {
      return .Failure(error as NSError)
  }
}

func jsonData(data: NSData, status: Int = 200, headers: [String:String]? = nil)(request:NSURLRequest) -> Response {
    var headers = headers ?? [String:String]()
    if headers["Content-Type"] == nil {
      headers["Content-Type"] = "application/json; charset=utf-8"
    }

    return http(status, headers: headers, data: data)(request:request)
}

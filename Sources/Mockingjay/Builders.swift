//
//  Builders.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 01/03/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation

// Collection of generic builders

internal struct MockingjayFailure: Error {}

/// Generic builder for returning a failure
public func failure(_ error: Error? = nil) -> (_ request: URLRequest) -> Response {
  return { _ in
    if let error = error {
      return .failure(error)
    }

    return .failure(MockingjayFailure())
  }
}

public func http(_ status:Int = 200, headers:[String:String]? = nil, download:Download=nil) -> (_ request: URLRequest) -> Response {
  return { (request:URLRequest) in
    if let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: headers) {
      return Response.success(response, download)
    }

    return .failure(NSError(domain: NSExceptionName.internalInconsistencyException.rawValue, code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to construct response for stub."]))
  }
}

public func text(_ body: String, using encoding: String.Encoding, status: Int = 200, headers: [String: String]? = nil) -> (_ request: URLRequest) -> Response {
  var headers = headers ?? [String:String]()
  if headers["Content-Type"] == nil && encoding == .utf8 {
    headers["Content-Type"] = "text/plain; charset=utf-8"
  }

  if let data = body.data(using: encoding) {
    return http(status, headers: headers, download: .content(data))
  }

  return failure()
}

public func json(_ body: Any, status:Int = 200, headers:[String:String]? = nil) -> (_ request: URLRequest) -> Response {
  return { (request:URLRequest) in
    do {
      let data = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
      return jsonData(data, status: status, headers: headers)(request)
    } catch {
      return .failure(error as NSError)
    }
  }
}

public func jsonData(_ data: Data, status: Int = 200, headers: [String:String]? = nil) -> (_ request: URLRequest) -> Response {
  return { (request:URLRequest) in
    var headers = headers ?? [String:String]()
    if headers["Content-Type"] == nil {
      headers["Content-Type"] = "application/json; charset=utf-8"
    }
    
    return http(status, headers: headers, download: .content(data))(request)
  }
}

public func redirect(to url: URL, status: Int = 301, headers: [String:String]? = nil) -> (_ request: URLRequest) -> Response {
  var headers = headers ?? [:]
  headers["Location"] = url.absoluteString

  let resoponse = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: headers)!
  return { request in
    return .success(resoponse, .noContent)
  }
}

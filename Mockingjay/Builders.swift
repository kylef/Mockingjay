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
public func failure(_ error: NSError) -> (_ request: URLRequest) -> Response {
  return { _ in return .failure(error) }
}

public func http(_ status:Int = 200, headers:[String:String]? = nil, download:Download=nil) -> (_ request: URLRequest) -> Response {
  return { (request:URLRequest) in
    if let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: headers) {
      return Response.success(response, download)
    }

    return .failure(NSError(domain: NSExceptionName.internalInconsistencyException.rawValue, code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to construct response for stub."]))
  }
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

public func content(_ body: String, status: Int = 200, headers: [String:String]? = nil) -> (_ request: URLRequest) -> Response {
    return { (request: URLRequest) in
        var headers = headers ?? [String:String]()
        if headers["Content-Type"] == nil {
            headers["Content-Type"] = "text/plain; charset=utf-8"
        }
        let data: Data = body.data(using: String.Encoding.utf8) ?? Data()
        return http(status, headers: headers, download: Download.content(data as Data))(request)
    }
}

public func file(_ file: String, _ type: String = "json", status: Int = 200, headers: [String:String]? = nil) -> (_ request: URLRequest) -> Response {
    return { (request: URLRequest) in
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        if let path = Bundle.main.path(forResource: file, ofType: type) {
            if let data = NSData(contentsOfFile: path) {
                return content(String(data: data as Data, encoding: .utf8) ?? "", status: status, headers: headers)(request)
            }
        }
        return .failure(NSError())
    }
}

//
//  Builders.swift
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

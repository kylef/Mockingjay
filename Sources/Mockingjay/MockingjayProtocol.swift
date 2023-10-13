//
//  MockingjayProtocol.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 28/02/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation


/// Structure representing a registered stub
public struct Stub : Equatable {
  let matcher:Matcher
  let delay: TimeInterval?
  let builder:Builder
  let uuid:UUID
  
  init(matcher:@escaping Matcher, delay: TimeInterval?, builder:@escaping Builder) {
    self.matcher = matcher
    self.delay = delay
    self.builder = builder
    uuid = UUID()
  }
}

public func ==(lhs:Stub, rhs:Stub) -> Bool {
  return lhs.uuid == rhs.uuid
}

class MockingjayStorage {
    static let shared = MockingjayStorage()
    
    var stubs: [Stub] {
        get { accessQueue.sync { _stubs } }
        set { accessQueue.sync { _stubs = newValue } }
    }
    
    var registered: Bool {
        get { accessQueue.sync { _registered } }
        set { accessQueue.sync { _registered = newValue } }
    }
    
    private var _stubs = [Stub]()
    private var _registered: Bool = false
    private var accessQueue: DispatchQueue { DispatchQueue(label: "MockingjayStorageQueue", qos: .default) }
}

public class MockingjayProtocol: URLProtocol {
  private class var storage: MockingjayStorage { .shared }
  private class var stubs: [Stub] {
      get { storage.stubs }
      set { storage.stubs = newValue }
  }
  private class var registered: Bool {
      get { storage.registered }
      set { storage.registered = newValue }
  }
  
  // MARK: Stubs
  fileprivate var enableDownloading = true
  fileprivate let operationQueue = OperationQueue()
  
  class func addStub(_ stub:Stub) -> Stub {
    stubs.append(stub)

    if !registered {
      URLProtocol.registerClass(MockingjayProtocol.self)
    }

    return stub
  }
  
  /// Register a matcher and a builder as a new stub
  @discardableResult open class func addStub(matcher: @escaping Matcher, delay: TimeInterval? = nil, builder: @escaping Builder) -> Stub {
    return addStub(Stub(matcher: matcher, delay: delay, builder: builder))
  }
  
  /// Unregister the given stub
  open class func removeStub(_ stub:Stub) {
    if let index = stubs.firstIndex(of: stub) {
      stubs.remove(at: index)
    }
  }
  
  /// Remove all registered stubs
  open class func removeAllStubs() {
    stubs.removeAll(keepingCapacity: false)
  }
  
  /// Finds the appropriate stub for a request
  /// This method searches backwards though the registered requests
  /// to find the last registered stub that handles the request.
  class func stubForRequest(_ request:URLRequest) -> Stub? {
    for stub in stubs.reversed() {
      if stub.matcher(request) {
        return stub
      }
    }
    
    return nil
  }
  
  // MARK: NSURLProtocol
  
  /// Returns whether there is a registered stub handler for the given request.
  override open class func canInit(with request:URLRequest) -> Bool {
    return stubForRequest(request) != nil
  }
  
  override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  override open func startLoading() {
    if let stub = MockingjayProtocol.stubForRequest(request) {
      let response = stub.builder(request)
      if let delay = stub.delay {
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + delay) {
          self.sendResponse(response)
        }
      } else {
        sendResponse(response)
      }
    } else {
      let error = NSError(domain: NSExceptionName.internalInconsistencyException.rawValue, code: 0, userInfo: [ NSLocalizedDescriptionKey: "Handling request without a matching stub." ])
      client?.urlProtocol(self, didFailWithError: error)
    }
  }
  
  override open func stopLoading() {
    self.enableDownloading = false
    self.operationQueue.cancelAllOperations()
  }
  
  // MARK: Private Methods

  func isRedirect(request: URLRequest, response: URLResponse) -> URLRequest? {
    guard
      let response = response as? HTTPURLResponse,
      response.statusCode == 301 || response.statusCode == 302 || response.statusCode == 303 || response.statusCode == 307,
      let location = response.allHeaderFields["Location"] as? String,
      let locationURL = URL(string: location, relativeTo: response.url)
    else { return nil }

    if response.statusCode == 307 {
      var redirectRequest = request
      redirectRequest.url = locationURL
      return redirectRequest
    }

    return URLRequest(url: locationURL)
  }
  
  fileprivate func sendResponse(_ response: Response) {
    switch response {
    case .failure(let error):
      client?.urlProtocol(self, didFailWithError: error)
    case .success(var response, let download):
      let headers = self.request.allHTTPHeaderFields

      if let redirectRequest = isRedirect(request: self.request, response: response) {
        client?.urlProtocol(self, wasRedirectedTo: redirectRequest, redirectResponse: response)
        return
      }
      
      switch(download) {
      case .content(var data):
        applyRangeFromHTTPHeaders(headers, toData: &data, andUpdateResponse: &response)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
      case .streamContent(data: var data, inChunksOf: let bytes):
        applyRangeFromHTTPHeaders(headers, toData: &data, andUpdateResponse: &response)
        self.download(data, inChunksOfBytes: bytes)
        return
      case .noContent:
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocolDidFinishLoading(self)
      }
    }
  }
  
  fileprivate func download(_ data:Data?, inChunksOfBytes bytes:Int) {
    guard let data = data else {
      client?.urlProtocolDidFinishLoading(self)
      return
    }
    self.operationQueue.maxConcurrentOperationCount = 1
    self.operationQueue.addOperation { () -> Void in
      self.download(data, fromOffset: 0, withMaxLength: bytes)
    }
  }
  
  
  fileprivate func download(_ data:Data, fromOffset offset:Int, withMaxLength maxLength:Int) {
    guard let queue = OperationQueue.current else {
      return
    }
    guard (offset < data.count) else {
      client?.urlProtocolDidFinishLoading(self)
      return
    }
    let length = min(data.count - offset, maxLength)
    
    queue.addOperation { () -> Void in
      guard self.enableDownloading else {
        self.enableDownloading = true
        return
      }
      
      let subdata = data.subdata(in: offset ..< (offset + length))
      self.client?.urlProtocol(self, didLoad: subdata)
      Thread.sleep(forTimeInterval: 0.01)
      self.download(data, fromOffset: offset + length, withMaxLength: maxLength)
    }
  }
  
  fileprivate func extractRangeFromHTTPHeaders(_ headers:[String : String]?) -> Range<Int>? {
    guard let rangeStr = headers?["Range"] else {
      return nil
    }
    let range = rangeStr.components(separatedBy: "=")[1].components(separatedBy: "-").map({ (str) -> Int in
      Int(str)!
    })
    let loc = range[0]
    let length = range[1] + 1
    return loc ..< length
  }
  
  fileprivate func applyRangeFromHTTPHeaders(
    _ headers:[String : String]?,
    toData data:inout Data,
    andUpdateResponse response:inout URLResponse) {
      guard let range = extractRangeFromHTTPHeaders(headers) else {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        return
      }
    
      let fullLength = data.count
      data = data.subdata(in: range)
      
      //Attach new headers to response
      if let r = response as? HTTPURLResponse {
        var header = r.allHeaderFields as! [String:String]
        header["Content-Length"] = String(data.count)
        header["Content-Range"] = "bytes \(range.lowerBound)-\(range.upperBound)/\(fullLength)"
        response = HTTPURLResponse(url: r.url!, statusCode: r.statusCode, httpVersion: nil, headerFields: header)!
      }
      
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
  }

}

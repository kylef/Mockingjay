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
  let builder:Builder
  let uuid:NSUUID
  
  init(matcher:Matcher, builder:Builder) {
    self.matcher = matcher
    self.builder = builder
    uuid = NSUUID()
  }
}

public func ==(lhs:Stub, rhs:Stub) -> Bool {
  return lhs.uuid == rhs.uuid
}

var stubs = [Stub]()

public class MockingjayProtocol : NSURLProtocol {
  // MARK: Stubs
  private var enableDownloading = true
  private let operationQueue = NSOperationQueue()
  
  class func addStub(stub:Stub) -> Stub {
    stubs.append(stub)
    
    var token: dispatch_once_t = 0
    dispatch_once(&token) {
      NSURLProtocol.registerClass(self)
      return
    }
    
    return stub
  }
  
  /// Register a matcher and a builder as a new stub
  public class func addStub(matcher:Matcher, builder:Builder) -> Stub {
    return addStub(Stub(matcher: matcher, builder: builder))
  }
  
  /// Unregister the given stub
  public class func removeStub(stub:Stub) {
    if let index = stubs.indexOf(stub) {
      stubs.removeAtIndex(index)
    }
  }
  
  /// Remove all registered stubs
  public class func removeAllStubs() {
    stubs.removeAll(keepCapacity: false)
  }
  
  /// Finds the appropriate stub for a request
  /// This method searches backwards though the registered requests
  /// to find the last registered stub that handles the request.
  class func stubForRequest(request:NSURLRequest) -> Stub? {
    for stub in stubs.reverse() {
      if stub.matcher(request) {
        return stub
      }
    }
    
    return nil
  }
  
  // MARK: NSURLProtocol
  
  /// Returns whether there is a registered stub handler for the given request.
  override public class func canInitWithRequest(request:NSURLRequest) -> Bool {
    return stubForRequest(request) != nil
  }
  
  override public class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
    return request
  }
  
  override public func startLoading() {
    if let stub = MockingjayProtocol.stubForRequest(request) {
      switch stub.builder(request) {
      case .Failure(let error):
        client?.URLProtocol(self, didFailWithError: error)
      case .Success(let response, let data):
        client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)

        if let data = data {
          client?.URLProtocol(self, didLoadData: data)
        }

        client?.URLProtocolDidFinishLoading(self)
      }
    } else {
      let error = NSError(domain: NSInternalInconsistencyException, code: 0, userInfo: [ NSLocalizedDescriptionKey: "Handling request without a matching stub." ])
      client?.URLProtocol(self, didFailWithError: error)
    }
  }
  
  override public func stopLoading() {
    self.enableDownloading = false
    self.operationQueue.cancelAllOperations()
  }
  
  // MARK: Private Methods
  
  private func download(data:NSData?, inChunksOfBytes bytes:Int) {
    guard let data = data else {
      client?.URLProtocolDidFinishLoading(self)
      return
    }
    self.operationQueue.maxConcurrentOperationCount = 1
    self.operationQueue.addOperationWithBlock { () -> Void in
      self.download(data, fromOffset: 0, withMaxLength: bytes)
    }
  }
  
  
  private func download(data:NSData, fromOffset offset:Int, withMaxLength maxLength:Int) {
    guard let queue = NSOperationQueue.currentQueue() else {
      return
    }
    guard (offset < data.length) else {
      client?.URLProtocolDidFinishLoading(self)
      return
    }
    let length = min(data.length - offset, maxLength)
    
    queue.addOperationWithBlock { () -> Void in
      guard self.enableDownloading else {
        self.enableDownloading = true
        return
      }
      
      let subdata = data.subdataWithRange(NSMakeRange(offset, length))
      self.client?.URLProtocol(self, didLoadData: subdata)
      NSThread.sleepForTimeInterval(0.01)
      self.download(data, fromOffset: offset + length, withMaxLength: maxLength)
    }
  }
  
  private func extractRangeFromHTTPHeaders(headers:[String : String]?) -> NSRange? {
    guard let rangeStr = headers?["Range"] else {
      return nil
    }
    let range = rangeStr.componentsSeparatedByString("=")[1].componentsSeparatedByString("-").map({ (str) -> Int in
      Int(str)!
    })
    let loc = range[0]
    let length = range[1] - loc + 1
    return NSMakeRange(loc, length)
  }
  
  private func applyRangeFromHTTPHeaders(
    headers:[String : String]?,
    inout toData data:NSData,
    inout andUpdateResponse response:NSURLResponse) {
      guard let range = extractRangeFromHTTPHeaders(headers) else {
        client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
        return
      }
      let fullLength = data.length
      data = data.subdataWithRange(range)
      
      //Attach new headers to response
      if let r = response as? NSHTTPURLResponse {
        var header = r.allHeaderFields as! [String:String]
        header["Content-Length"] = String(data.length)
        header["Content-Range"] = String(range.httpRangeStringWithFullLength(fullLength))
        response = NSHTTPURLResponse(URL: r.URL!, statusCode: r.statusCode, HTTPVersion: nil, headerFields: header)!
      }
      
      client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
  }
  
}

extension NSRange {
  func httpRangeStringWithFullLength(fullLength:Int) -> String {
    let endLoc = self.location + self.length - 1
    return "bytes " + String(self.location) + "-" + String(endLoc) + "/" + String(fullLength)
  }
}

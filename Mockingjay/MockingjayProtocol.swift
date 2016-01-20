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

  override public func stopLoading() {}
}

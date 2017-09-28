//
//  MockingjayAsyncProtocolTests.swift
//  Mockingjay
//
//  Created by Stuart Lynch on 22/01/2016.
//  Copyright © 2016 Cocode. All rights reserved.
//

import Foundation
import XCTest
import Mockingjay

class MockingjayAsyncProtocolTests: XCTestCase, URLSessionDataDelegate  {
  
  typealias DidReceiveDataHandler = (_ session: Foundation.URLSession, _ dataTask: URLSessionDataTask, _ data: Data) -> ()
  var didReceiveDataHandler:DidReceiveDataHandler?
  var configuration:URLSessionConfiguration!
  
  override func setUp() {
    super.setUp()
    var protocolClasses = [AnyClass]()
    protocolClasses.append(MockingjayProtocol.self)
    
    configuration = URLSessionConfiguration.default
    configuration.protocolClasses = protocolClasses
  }
  
  override func tearDown() {
    super.tearDown()
    MockingjayProtocol.removeAllStubs()
  }
  
  // MARK: Tests
  
  func testDownloadOfTextInChunks() {
    let request = URLRequest(url: URL(string: "https://fuller.li/")!)
    let stubResponse = URLResponse(url: request.url!, mimeType: "text/plain", expectedContentLength: 6, textEncodingName: "utf-8")
    let stubData = "Two things are infinite: the universe and human stupidity; and I'm not sure about the universe.".data(using: String.Encoding.utf8, allowLossyConversion: true)!
    
    MockingjayProtocol.addStub(matcher: { (requestedRequest) -> (Bool) in
      return true
    }) { (request) -> (Response) in
      return Response.success(stubResponse, .streamContent(data: stubData, inChunksOf: 22))
    }
    
    let urlSession = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.current)
    let dataTask = urlSession.dataTask(with: request)
    dataTask.resume()
    
    let mutableData = NSMutableData()
    while mutableData.length < stubData.count {
      let expectation = self.expectation(description: "testProtocolCanReturnedDataInChunks")
      self.didReceiveDataHandler = { (session: Foundation.URLSession, dataTask: URLSessionDataTask, data: Data) in
        mutableData.append(data)
        expectation.fulfill()
      }
      waitForExpectations(timeout: 2.0, handler: nil)
    }
    XCTAssertEqual(mutableData as Data, stubData)
  }
  
  func testDownloadOfAudioFileInChunks() {
    let request = URLRequest(url: URL(string: "https://fuller.li/")!)
    let path = Bundle(for: self.classForCoder).path(forResource: "TestAudio", ofType: "m4a")
    let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
    
    let stubResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "1.1", headerFields: ["Content-Length" : String(data.count)])!
    
    MockingjayProtocol.addStub(matcher: { (requestedRequest) -> (Bool) in
      return true
    }) { (request) -> (Response) in
      return Response.success(stubResponse, Download.streamContent(data: data, inChunksOf: 2000))
    }
    let urlSession = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.current)
    let dataTask = urlSession.dataTask(with: request)
    dataTask.resume()
    
    let mutableData = NSMutableData()
    while mutableData.length < data.count {
      let expectation = self.expectation(description: "testProtocolCanReturnedDataInChunks")
      self.didReceiveDataHandler = { (session: Foundation.URLSession, dataTask: URLSessionDataTask, data: Data) in
        mutableData.append(data)
        expectation.fulfill()
      }
      waitForExpectations(timeout: 2.0, handler: nil)
    }
    XCTAssertEqual(mutableData as Data, data)
  }
  
  func testByteRanges() {
    let length = 100000
    var request = URLRequest(url: URL(string: "https://fuller.li/")!)
    request.addValue("bytes=50000-149999", forHTTPHeaderField: "Range")
    let path = Bundle(for: self.classForCoder).path(forResource: "TestAudio", ofType: "m4a")
    let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
    
    let stubResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "1.1", headerFields: ["Content-Length" : String(length)])!
    MockingjayProtocol.addStub(matcher: { (requestedRequest) -> (Bool) in
      return true
    }) { (request) -> (Response) in
      return Response.success(stubResponse, .streamContent(data: data, inChunksOf: 2000))
    }
    
    let urlSession = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.current)
    let dataTask = urlSession.dataTask(with: request)
    dataTask.resume()
    
    var mutableData = Data()
    while mutableData.count < length {
      let expectation = self.expectation(description: "testProtocolCanReturnedDataInChunks")
      self.didReceiveDataHandler = { (session: Foundation.URLSession, dataTask: URLSessionDataTask, data: Data) in
        mutableData.append(data)
        expectation.fulfill()
      }
      waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    let correctData = data.subdata(in: 50000 ..< (50000 + length))
    XCTAssertEqual(mutableData, correctData)
  }
  
  // MARK: NSURLSessionDataDelegate
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    self.didReceiveDataHandler?(session, dataTask, data)
  }
  
}

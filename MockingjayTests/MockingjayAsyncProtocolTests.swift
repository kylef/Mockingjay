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

class MockingjayAsyncProtocolTests: XCTestCase, NSURLSessionDataDelegate  {
  
  typealias DidReceiveDataHandler = (session: NSURLSession, dataTask: NSURLSessionDataTask, data: NSData) -> ()
  var didReceiveDataHandler:DidReceiveDataHandler?
  var configuration:NSURLSessionConfiguration!
  
  override func setUp() {
    super.setUp()
    var protocolClasses = [AnyClass]()
    protocolClasses.append(MockingjayProtocol)
    
    configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    configuration.protocolClasses = protocolClasses
  }
  
  override func tearDown() {
    super.tearDown()
    MockingjayProtocol.removeAllStubs()
  }
  
  // MARK: Tests
  
//  func testDownloadOfTextInChunks() {
//    let request = NSURLRequest(URL: NSURL(string: "https://fuller.li/")!)
//    let stubResponse = NSURLResponse(URL: request.URL!, MIMEType: "text/plain", expectedContentLength: 6, textEncodingName: "utf-8")
//    let stubData = "Two things are infinite: the universe and human stupidity; and I'm not sure about the universe.".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
//    
//    MockingjayProtocol.addStub({ (requestedRequest) -> (Bool) in
//      return true
//      }) { (request) -> (Response) in
//        return Response.Success(stubResponse, .StreamContent(data: stubData, inChunksOf: 22))
//    }
//    
//    let urlSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.currentQueue())
//    let dataTask = urlSession.dataTaskWithRequest(request)
//    dataTask.resume()
//    
//    let mutableData = NSMutableData()
//    while mutableData.length < stubData.length {
//      let expectation = expectationWithDescription("testProtocolCanReturnedDataInChunks")
//      self.didReceiveDataHandler = { (session: NSURLSession, dataTask: NSURLSessionDataTask, data: NSData) in
//        mutableData.appendData(data)
//        expectation.fulfill()
//      }
//      waitForExpectationsWithTimeout(2.0, handler: nil)
//    }
//    XCTAssertEqual(mutableData, stubData)
//  }
  
//  func testDownloadOfAudioFileInChunks() {
//    let request = NSURLRequest(URL: NSURL(string: "https://fuller.li/")!)
//    let path = NSBundle(forClass: self.classForCoder).pathForResource("TestAudio", ofType: "m4a")
//    let data = NSData(contentsOfFile: path!)!
//    
//    let stubResponse = NSHTTPURLResponse(URL: request.URL!, statusCode: 200, HTTPVersion: "1.1", headerFields: ["Content-Length" : String(data.length)])!
//    
//    MockingjayProtocol.addStub({ (requestedRequest) -> (Bool) in
//      return true
//      }) { (request) -> (Response) in
//        return Response.Success(stubResponse, Download.StreamContent(data: data, inChunksOf: 2000))
//    }
//    let urlSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.currentQueue())
//    let dataTask = urlSession.dataTaskWithRequest(request)
//    dataTask.resume()
//    
//    let mutableData = NSMutableData()
//    while mutableData.length < data.length {
//      let expectation = expectationWithDescription("testProtocolCanReturnedDataInChunks")
//      self.didReceiveDataHandler = { (session: NSURLSession, dataTask: NSURLSessionDataTask, data: NSData) in
//        mutableData.appendData(data)
//        expectation.fulfill()
//      }
//      waitForExpectationsWithTimeout(2.0, handler: nil)
//    }
//    XCTAssertEqual(mutableData, data)
//  }
  
//  func testByteRanges() {
//    let length = 100000
//    let request = NSMutableURLRequest(URL: NSURL(string: "https://fuller.li/")!)
//    request.addValue("bytes=50000-149999", forHTTPHeaderField: "Range")
//    let path = NSBundle(forClass: self.classForCoder).pathForResource("TestAudio", ofType: "m4a")
//    let data = NSData(contentsOfFile: path!)!
//    
//    let stubResponse = NSHTTPURLResponse(URL: request.URL!, statusCode: 200, HTTPVersion: "1.1", headerFields: ["Content-Length" : String(length)])!
//    MockingjayProtocol.addStub({ (requestedRequest) -> (Bool) in
//      return true
//      }) { (request) -> (Response) in
//        return Response.Success(stubResponse, .StreamContent(data: data, inChunksOf: 2000))
//    }
//    
//    let urlSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.currentQueue())
//    let dataTask = urlSession.dataTaskWithRequest(request)
//    dataTask.resume()
//    
//    let mutableData = NSMutableData()
//    while mutableData.length < length {
//      let expectation = expectationWithDescription("testProtocolCanReturnedDataInChunks")
//      self.didReceiveDataHandler = { (session: NSURLSession, dataTask: NSURLSessionDataTask, data: NSData) in
//        mutableData.appendData(data)
//        expectation.fulfill()
//      }
//      waitForExpectationsWithTimeout(2.0, handler: nil)
//    }
//    XCTAssertEqual(mutableData, data.subdataWithRange(NSMakeRange(50000, length)))
//  }
  
  // MARK: NSURLSessionDataDelegate
  func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
    self.didReceiveDataHandler?(session: session, dataTask: dataTask, data:data)
  }
  
}

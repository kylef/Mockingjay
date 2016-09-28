//
//  Mockingjay.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 28/02/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation

public enum Download: NilLiteralConvertible, Equatable {
  public init(nilLiteral: ()) {
    self = .NoContent
  }
  
  //Simulate download in one step
  case Content(NSData)
  //Simulate download as byte stream
  case StreamContent(data:NSData, inChunksOf:Int)
  //Simulate empty download
  case NoContent
}

public func ==(lhs:Download, rhs:Download) -> Bool {
  switch(lhs, rhs) {
  case let (.Content(lhsData), .Content(rhsData)):
    return lhsData.isEqualToData(rhsData)
  case let (.StreamContent(data:lhsData, inChunksOf:lhsBytes), .StreamContent(data:rhsData, inChunksOf:rhsBytes)):
    return lhsData.isEqualToData(rhsData) && lhsBytes == rhsBytes
  case (.NoContent, .NoContent):
    return true
  default:
    return false
  }
}

public enum Response : Equatable {
  case Success(NSURLResponse, NSData?)
  case Failure(NSError)
}

public func ==(lhs:Response, rhs:Response) -> Bool {
  switch (lhs, rhs) {
  case let (.Failure(lhsError), .Failure(rhsError)):
    return lhsError == rhsError
  case let (.Success(lhsResponse, lhsDownload), .Success(rhsResponse, rhsDownload)):
    return lhsResponse == rhsResponse && lhsDownload == rhsDownload
  default:
    return false
  }
}

public typealias Matcher = (NSURLRequest) -> (Bool)
public typealias Builder = (NSURLRequest) -> (Response)

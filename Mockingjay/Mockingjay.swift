//
//  Mockingjay.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 28/02/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation

public enum Download: ExpressibleByNilLiteral, Equatable {
  public init(nilLiteral: ()) {
    self = .noContent
  }
  
  // Simulate download in one step
  case content(Data)

  // Simulate download as byte stream
  case streamContent(data:Data, inChunksOf:Int)

  // Simulate empty download
  case noContent
}

public func ==(lhs:Download, rhs:Download) -> Bool {
  switch(lhs, rhs) {
  case let (.content(lhsData), .content(rhsData)):
    return (lhsData == rhsData)
  case let (.streamContent(data:lhsData, inChunksOf:lhsBytes), .streamContent(data:rhsData, inChunksOf:rhsBytes)):
    return (lhsData == rhsData) && lhsBytes == rhsBytes
  case (.noContent, .noContent):
    return true
  default:
    return false
  }
}

public enum Response : Equatable {
  case success(URLResponse, Download)
  case failure(NSError)
}

public func ==(lhs:Response, rhs:Response) -> Bool {
  switch (lhs, rhs) {
  case let (.failure(lhsError), .failure(rhsError)):
    return lhsError == rhsError
  case let (.success(lhsResponse, lhsDownload), .success(rhsResponse, rhsDownload)):
    return lhsResponse == rhsResponse && lhsDownload == rhsDownload
  default:
    return false
  }
}

public typealias Matcher = (URLRequest) -> (Bool)
public typealias Builder = (URLRequest) -> (Response)

//
//  Mockingjay.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 28/02/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation

//Optionlly simulate data stream
public enum DownloadOption : Equatable {
  case DownloadAll
  case DownloadInChunksOf(bytes:Int)
}

public func ==(lhs:DownloadOption, rhs:DownloadOption) -> Bool {
  switch(lhs) {
  case .DownloadAll:
    return rhs == .DownloadAll
  case .DownloadInChunksOf(bytes: let lhsBytes):
    switch(rhs) {
    case .DownloadAll:
      return false
    case.DownloadInChunksOf(bytes: let rhsBytes):
      return lhsBytes == rhsBytes
    }
  }
}

public enum Response : Equatable {
  case Success(NSURLResponse, NSData?, DownloadOption)
  case Failure(NSError)
}

public func ==(lhs:Response, rhs:Response) -> Bool {
  switch (lhs, rhs) {
  case let (.Failure(lhsError), .Failure(rhsError)):
    return lhsError == rhsError
  case let (.Success(lhsResponse, lhsData, lhsDownloadOption), .Success(rhsResponse, rhsData, rhsDownloadOption)):
    return lhsResponse == rhsResponse && lhsData == rhsData && lhsDownloadOption == rhsDownloadOption
  default:
    return false
  }
}

public typealias Matcher = (NSURLRequest) -> (Bool)
public typealias Builder = (NSURLRequest) -> (Response)

//
//  Mockingjay.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 28/02/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation

public enum Response : Equatable {
  case Success(NSURLResponse, NSData?)
  case Failure(NSError)
}

public func ==(lhs:Response, rhs:Response) -> Bool {
  switch (lhs, rhs) {
  case let (.Failure(lhsError), .Failure(rhsError)):
    return lhsError == rhsError
  case let (.Success(lhsResponse, lhsData), .Success(rhsResponse, rhsData)):
    return lhsResponse == rhsResponse && lhsData == rhsData
  default:
    return false
  }
}

public typealias Matcher = (NSURLRequest) -> (Bool)
public typealias Builder = (NSURLRequest) -> (Response)

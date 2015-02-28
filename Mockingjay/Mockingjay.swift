//
//  Mockingjay.swift
//  Mockingjay
//
//  Created by Kyle Fuller on 28/02/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

import Foundation

public enum Response {
  case Success(response:NSURLResponse, data:NSData?)
  case Failure(NSError)
}

public typealias Matcher = (NSURLRequest) -> (Bool)
public typealias Builder = (NSURLRequest) -> (Response)

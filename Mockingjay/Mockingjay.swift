//
//  Mockingjay.swift
//  Mockingjay
//
//  Copyright (c) 2015, Kyle Fuller
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  * Neither the name of Mockingjay nor the names of its
//  contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
  case Success(NSURLResponse, Download)
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

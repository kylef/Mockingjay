//
//  XCTest+XCTest.m
//  Mockingjay
//
//  Created by Kyle Fuller on 01/03/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

#import <objc/runtime.h>
#import <XCTest/XCTest.h>
#import <Mockingjay/Mockingjay.h>

// TODO Figure out how to do this in Swift.
// Boris, you like a challenge? ;)

@interface XCTest (XCTest)

@end


@implementation XCTest (XCTest)

+ (void)initialize {
  if (self == [XCTest class]) {
    Method tearDown = class_getInstanceMethod(self, @selector(tearDown));
    Method mockingjayTearDown = class_getInstanceMethod(self, @selector(mockingjayTearDown));
    method_exchangeImplementations(tearDown, mockingjayTearDown);
  }
}

- (void)mockingjayTearDown {
  [self mockingjayTearDown];
  [MockingjayProtocol removeAllStubs];
}

@end

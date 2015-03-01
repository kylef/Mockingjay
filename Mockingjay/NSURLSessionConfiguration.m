//
//  NSURLSessionConfiguration+Mockingjay.m
//  Mockingjay
//
//  Created by Kyle Fuller on 01/03/2015.
//  Copyright (c) 2015 Cocode. All rights reserved.
//

#import <objc/objc-runtime.h>
#import <Foundation/Foundation.h>
#import <Mockingjay/Mockingjay-Swift.h>

// TODO Rewrite in Swift.

@interface NSURLSessionConfiguration (Mockingjay)

@end

@implementation NSURLSessionConfiguration (Mockingjay)

+ (void)initialize {
  if (self == [NSURLSessionConfiguration class]) {
    Method defaultSessionConfiguration = class_getClassMethod(self, @selector(defaultSessionConfiguration));
    Method mockingjayDefaultSessionConfiguration = class_getClassMethod(self, @selector(mockingjayDefaultSessionConfiguration));
    method_exchangeImplementations(defaultSessionConfiguration, mockingjayDefaultSessionConfiguration);

    Method ephemeralSessionConfiguration = class_getClassMethod(self, @selector(ephemeralSessionConfiguration));
    Method mockingjayEphemeralSessionConfiguration = class_getClassMethod(self, @selector(mockingjayEphemeralSessionConfiguration));
    method_exchangeImplementations(ephemeralSessionConfiguration, mockingjayEphemeralSessionConfiguration);
  }
}

+ (NSURLSessionConfiguration *)mockingjayDefaultSessionConfiguration {
  NSURLSessionConfiguration *sessionConfiguration = [self mockingjayDefaultSessionConfiguration];
  NSMutableArray *protocolClasses = [sessionConfiguration.protocolClasses mutableCopy];
  [protocolClasses insertObject:MockingjayProtocol.class atIndex:0];
  sessionConfiguration.protocolClasses = protocolClasses;
  return sessionConfiguration;
}

+ (NSURLSessionConfiguration *)mockingjayEphemeralSessionConfiguration {
  NSURLSessionConfiguration *sessionConfiguration = [self mockingjayEphemeralSessionConfiguration];
  NSMutableArray *protocolClasses = [sessionConfiguration.protocolClasses mutableCopy];
  [protocolClasses insertObject:MockingjayProtocol.class atIndex:0];
  sessionConfiguration.protocolClasses = protocolClasses;
  return sessionConfiguration;
}

@end

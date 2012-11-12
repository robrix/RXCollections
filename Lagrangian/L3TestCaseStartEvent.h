//  L3TestCaseStartEvent.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3Event.h"

@class L3TestCase;

@interface L3TestCaseStartEvent : L3Event

+(instancetype)eventWithTestCase:(L3TestCase *)testCase;

@property (strong, nonatomic, readonly) L3TestCase *testCase;

@end

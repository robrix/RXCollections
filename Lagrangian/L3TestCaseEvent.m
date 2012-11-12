//  L3TestCaseEvent.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCaseEvent.h"

@implementation L3TestCaseEvent

#pragma mark -
#pragma mark Constructors

+(instancetype)eventWithTestCase:(L3TestCase *)testCase date:(NSDate *)date {
	return [[self alloc] initWithTestCase:testCase date:date];
}

-(instancetype)initWithTestCase:(L3TestCase *)testCase date:(NSDate *)date {
	if ((self = [super initWithDate:date])) {
		_testCase = testCase;
	}
	return self;
}

@end

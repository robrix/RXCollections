//  L3EventSink.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3EventFactory.h"
#import "L3EventSink.h"

@interface L3EventSink ()

@property (strong, nonatomic, readonly) L3EventFactory *factory;
@property (strong, nonatomic, readonly) NSMutableArray *mutableEvents;

@end

@implementation L3EventSink

#pragma mark -
#pragma mark Constructors

-(instancetype)init {
	if ((self = [super init])) {
		_factory = [L3EventFactory new];
		_mutableEvents = [NSMutableArray new];
	}
	return self;
}


#pragma mark -
#pragma mark Events

-(L3Event *)addEvent:(L3Event *)event {
	[self.mutableEvents addObject:event];
	[self.delegate eventSink:self didAddEvent:event];
	return event;
}


-(NSArray *)events {
	return self.mutableEvents;
}


#pragma mark -
#pragma mark Event algebra

-(L3Event *)testSuiteStartEventWithTestSuite:(L3TestSuite *)testSuite {
	return [self addEvent:[self.factory testSuiteStartEventWithTestSuite:testSuite]];
}

-(L3Event *)testSuiteEndEventWithTestSuite:(L3TestSuite *)testSuite {
	return [self addEvent:[self.factory testSuiteEndEventWithTestSuite:testSuite]];
}


-(L3Event *)testCaseStartEventWithTestCase:(L3TestCase *)testCase {
	return [self addEvent:[self.factory testCaseStartEventWithTestCase:testCase]];
}

-(L3Event *)testCaseEndEventWithTestCase:(L3TestCase *)testCase {
	return [self addEvent:[self.factory testCaseEndEventWithTestCase:testCase]];
}


-(L3Event *)assertionFailureWithAssertionReference:(L3AssertionReference *)assertionReference {
	return [self addEvent:[self.factory assertionFailureWithAssertionReference:assertionReference]];
}

-(L3Event *)assertionSuccessWithAssertionReference:(L3AssertionReference *)assertionReference {
	return [self addEvent:[self.factory assertionSuccessWithAssertionReference:assertionReference]];
}

@end

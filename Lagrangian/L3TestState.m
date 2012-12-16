//  L3TestState.m
//  Created by Rob Rix on 2012-11-10.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestState.h"
#import "Lagrangian.h"

@l3_suite("Test state");

const NSTimeInterval L3TestStateDefaultTimeout = 5.;

@interface L3TestState ()

@property (nonatomic, readonly) NSMutableDictionary *contents;

@property (strong, nonatomic, readonly) dispatch_semaphore_t completionSemaphore;

@property (assign, nonatomic, readwrite, getter = isDeferred) bool deferred;

@end

@implementation L3TestState

#pragma mark Constructors

-(instancetype)initWithSuite:(L3TestSuite *)suite eventObserver:(id<L3EventObserver>)eventObserver {
	if((self = [super init])) {
		_contents = [NSMutableDictionary new];
		_completionSemaphore = dispatch_semaphore_create(0);
		
		_suite = suite;
		_eventObserver = eventObserver;
		
		_timeout = L3TestStateDefaultTimeout;
	}
	return self;
}


#pragma mark Test state

-(id)objectForKeyedSubscript:(NSString *)key {
	NSParameterAssert(key != nil);
	return self.contents[key];
}

-(void)setObject:(id)object forKeyedSubscript:(NSString *)key {
	NSParameterAssert(object != nil);
	NSParameterAssert(key != nil);
	self.contents[key] = object;
}


#pragma mark Asynchrony

@l3_test("can explicitly wait for asynchronous results to complete") {
	__block NSString *text = nil;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		text = @"text";
		l3_complete();
	});
	l3_assert(l3_wait(), l3_did_not_timeout());
	l3_assert(text, l3_equals(@"text"));
}

@l3_test("can implicitly wait for asynchronous results to complete") {
	l3_defer();
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		l3_assert(test.isDeferred, YES);
		l3_complete();
	});
}

-(void)deferCompletion {
	self.deferred = YES;
}

-(void)complete {
	dispatch_semaphore_signal(self.completionSemaphore);
}

-(bool)wait {
	return [self waitWithTimeout:self.timeout];
}

-(bool)waitWithTimeout:(NSTimeInterval)interval {
	bool didTimeout =  dispatch_semaphore_wait(self.completionSemaphore, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC)) != 0;
	self.deferred = NO;
	return !didTimeout;
}

@end

//  L3TestCase.m
//  Created by Rob Rix on 2012-11-08.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCase.h"
#import "L3TestState.h"
#import "L3TestSuite.h"
#import "Lagrangian.h"

@interface L3TestCase ()

@property (copy, nonatomic, readwrite) NSString *name;

@end

@l3_suite("Test cases");

@implementation L3TestCase

static void test_function(L3TestState *state, L3TestSuite *suite, L3TestCase *testCase) {}

@l3_test("correlate names with functions") {
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"test case name" function:test_function];
	l3_assert(testCase.name, l3_equalTo(@"test case name"));
	__typeof__(nil) object = nil;
	l3_assert(testCase.function, l3_not(object));
}

+(instancetype)testCaseWithName:(NSString *)name function:(L3TestCaseFunction)function {
	return [[self alloc] initWithName:name function:function];
}

-(instancetype)initWithName:(NSString *)name function:(L3TestCaseFunction)function {
	NSParameterAssert(name != nil);
	NSParameterAssert(function != nil);
	if((self = [super init])) {
		_name = [name copy];
		_function = function;
	}
	return self;
}


-(void)runInSuite:(L3TestSuite *)suite {
	NSLog(@"running test case %@", self.name);
	@autoreleasepool {
		L3TestState *state = [suite.stateClass new];
		if (suite.setUpFunction)
			suite.setUpFunction(state, suite, self);
		
		self.function(state, suite, self);
		
		if (suite.tearDownFunction)
			suite.tearDownFunction(state, suite, self);
	}
}


@l3_test("return true for passing assertions") {
	bool matched = [_case assertThat:@"a" matches:^bool(id obj) { return YES; }];
	l3_assert(matched, l3_is(YES));
}

@l3_test("return false for failing assertions") {
	bool matched = [_case assertThat:@"a" matches:^bool(id obj){ return NO; }];
	l3_assert(matched, l3_is(NO));
}

-(bool)assertThat:(id)object matches:(L3Pattern)pattern {
	bool matched = pattern(object);
//	if (!matched)
//		NSLog(@"%@ failed!", self.name);
	return matched;
}

@end

//  L3TestCase.m
//  Created by Rob Rix on 2012-11-08.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3SourceReference.h"
#import "L3TestCase.h"
#import "L3TestState.h"
#import "L3TestSuite.h"
#import "Lagrangian.h"

#import "NSException+L3OCUnitCompatibility.h"

@l3_suite_interface(L3TestCase, "Test cases") <L3EventObserver>

@property NSMutableArray *events;

@end

@l3_set_up {
	test.events = [NSMutableArray new];
}


@interface L3TestCase ()

@property (nonatomic) L3TestState *state;

@property (copy, nonatomic, readwrite) NSString *name;

@property (copy, nonatomic, readwrite) NSString *file;
@property (assign, nonatomic, readwrite) NSUInteger line;

@property (assign, nonatomic, readwrite) NSUInteger failedAssertionCount;

@end

@implementation L3TestCase

static void test_function(L3TestState *state, L3TestCase *testCase) {}

#pragma mark Constructors

@l3_test("correlate names with functions") {
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"test case name" file:@"" __FILE__ line:__LINE__ function:test_function];
	l3_assert(testCase.name, l3_equalTo(@"test case name"));
	__typeof__(nil) object = nil;
	l3_assert(testCase.function, l3_not(object));
}

+(instancetype)testCaseWithName:(NSString *)name file:(NSString *)file line:(NSUInteger)line function:(L3TestCaseFunction)function {
	return [[self alloc] initWithName:name file:file line:line function:function];
}

-(instancetype)initWithName:(NSString *)name file:(NSString *)file line:(NSUInteger)line function:(L3TestCaseFunction)function {
	NSParameterAssert(name != nil);
	NSParameterAssert(function != nil);
	if((self = [super init])) {
		_name = [name copy];
		_file = [file copy];
		_line = line;
		_function = function;
	}
	return self;
}


#pragma mark Steps

-(void)setUp:(L3TestStep *)step withState:(L3TestState *)state {
	self.state = state;
	if (step)
		[self performStep:step withState:state];
}

-(void)tearDown:(L3TestStep *)step withState:(L3TestState *)state {
	if (step)
		[self performStep:step withState:state];
	self.state = nil;
}

-(bool)performStep:(L3TestStep *)step withState:(L3TestState *)state {
	NSParameterAssert(step != nil);
	NSParameterAssert(state != nil);
	
	NSUInteger previousFailedAssertionCount = self.failedAssertionCount;
	
	step.function(state, self, step);
	
	return previousFailedAssertionCount == self.failedAssertionCount;
}


#pragma mark L3Test

-(bool)isComposite {
	return NO;
}


#pragma mark Assertions

@l3_test("create source references for events applying to the case as a whole") {
	L3TestCase *testCase = [L3TestCase testCaseWithName:@"test case" file:@"file.m" line:42 function:test_function];
	L3SourceReference *reference = [testCase sourceReferenceForCaseEvents];
	l3_assert(reference.file, l3_equals(@"file.m"));
	l3_assert(reference.line, l3_equals(42));
	l3_assert(reference.subject, l3_equals(testCase));
	l3_assert(reference.subjectSource, l3_equals(@"test case"));
	l3_assert(reference.patternSource, l3_equals(nil));
}

-(L3SourceReference *)sourceReferenceForCaseEvents {
	return [L3SourceReference referenceWithFile:self.file line:self.line subjectSource:self.name subject:self patternSource:nil];
}


@l3_test("return true for passing assertions") {
	bool matched = [self assertThat:@"a" matches:^bool(id obj) { return YES; } sourceReference:l3_sourceReference(@"a", @"a", @".") eventObserver:nil];
	l3_assert(matched, l3_is(YES));
}

@l3_test("return false for failing assertions") {
	bool matched = [self assertThat:@"a" matches:^bool(id obj){ return NO; } sourceReference:l3_sourceReference(@"a", @"a", @"!") eventObserver:nil];
	l3_assert(matched, l3_is(NO));
}

@l3_test("generate assertion succeeded events for successful assertions") {
	L3SourceReference *sourceReference = l3_sourceReference(@"a", @"a", @".");
	[self assertThat:@"a" matches:^bool(id x) { return YES; } sourceReference:sourceReference eventObserver:test];
	
	l3_assert(test.events.lastObject[@"sourceReference"], l3_equals(sourceReference));
}

@l3_test("generate assertion failed events for failed assertions") {
	L3SourceReference *sourceReference = l3_sourceReference(@"a", @"a", @"!");
	[self assertThat:@"a" matches:^bool(id x) { return NO; } sourceReference:sourceReference eventObserver:test];
	
	l3_assert(test.events.lastObject[@"sourceReference"], l3_equals(sourceReference));
}

-(bool)assertThat:(id)object matches:(L3Pattern)pattern sourceReference:(L3SourceReference *)sourceReference eventObserver:(id<L3EventObserver>)eventObserver {
	// fixme: assertion start event
	bool matched = pattern(object);
	if (matched)
		[eventObserver assertionSuccessWithSourceReference:sourceReference date:[NSDate date]];
	else
		[eventObserver assertionFailureWithSourceReference:sourceReference date:[NSDate date]];
	
	self.failedAssertionCount += !matched;
	return matched;
}


#pragma mark Visitors

-(void)acceptVisitor:(id<L3TestVisitor>)visitor inTestSuite:(L3TestSuite *)parentSuite {
	[visitor testCase:self inTestSuite:parentSuite];
}

-(void)acceptVisitor:(id<L3TestVisitor>)visitor {
	[self acceptVisitor:visitor inTestSuite:nil];
}


#pragma mark Expecta

-(void)failWithException:(NSException *)exception {
	L3SourceReference *reference = [L3SourceReference referenceWithFile:exception.filename line:exception.lineNumber.unsignedIntegerValue reason:exception.reason];
	[self.state.eventObserver assertionFailureWithSourceReference:reference date:[NSDate date]];
	self.failedAssertionCount++;
}

@end


@l3_suite_implementation (L3TestCase)

-(void)testStartEventWithTest:(id<L3Test>)test date:(NSDate *)date {
	[self.events addObject:@{ @"name": test.name, @"date": date, @"type": @"start" }];
}

-(void)testEndEventWithTest:(id<L3Test>)test date:(NSDate *)date {
	[self.events addObject:@{ @"name": test.name, @"date": date, @"type": @"end" }];
}

-(void)assertionSuccessWithSourceReference:(L3SourceReference *)sourceReference date:(NSDate *)date {
	[self.events addObject:@{ @"sourceReference": sourceReference, @"date": date, @"type": @"success" }];
}

-(void)assertionFailureWithSourceReference:(L3SourceReference *)sourceReference date:(NSDate *)date {
	[self.events addObject:@{ @"sourceReference": sourceReference, @"date": date, @"type": @"failure" }];
}

@end

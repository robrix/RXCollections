//  L3TestSuite.m
//  Created by Rob Rix on 2012-11-07.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestCase.h"
#import "L3TestSuite.h"
#import "L3TestState.h"
#import "Lagrangian.h"
#import <dlfcn.h>

@l3_suite_interface (L3TestSuite) <L3TestVisitor>
@property NSMutableArray *visitedTests;
@end

@l3_set_up {
	test.visitedTests = [NSMutableArray new];
}


NSString * const L3TestSuiteSetUpStepName = @"set up";
NSString * const L3TestSuiteTearDownStepName = @"tear down";


@interface L3TestSuite ()

@property (copy, nonatomic, readwrite) NSString *name;

@property (copy, nonatomic, readwrite) NSString *file;
@property (assign, nonatomic, readwrite) NSUInteger line;

@property (strong, nonatomic, readonly) NSMutableArray *mutableTests;
@property (strong, nonatomic, readonly) NSMutableDictionary *mutableTestsByName;

@property (strong, nonatomic, readonly) NSMutableDictionary *mutableSteps;

@end

@implementation L3TestSuite

#pragma mark Constructors

+(instancetype)defaultSuite {
	static L3TestSuite *defaultSuite = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		defaultSuite = [self testSuiteWithName:[NSBundle mainBundle].bundlePath.lastPathComponent ?: [NSProcessInfo processInfo].processName];
	});
	return defaultSuite;
}


+(instancetype)testSuiteWithName:(NSString *)name file:(NSString *)file line:(NSUInteger)line {
	return [[self alloc] initWithName:name file:file line:line];
}

+(instancetype)testSuiteWithName:(NSString *)name {
	return [[self alloc] initWithName:name file:nil line:0];
}

-(instancetype)initWithName:(NSString *)name file:(NSString *)file line:(NSUInteger)line {
	NSParameterAssert(name != nil);
	if ((self = [super init])) {
		_name = [name copy];
		
		_file = [file copy];
		_line = line;
		
		_stateClass = [L3TestState class];
		
		_mutableTests = [NSMutableArray new];
		_mutableTestsByName = [NSMutableDictionary new];
		
		_mutableSteps = [NSMutableDictionary new];
	}
	return self;
}


#pragma mark Tests

-(void)addTest:(id<L3Test>)test {
	NSParameterAssert(test != nil);
	NSParameterAssert([self.testsByName objectForKey:test.name] == nil);
	
	[self.mutableTests addObject:test];
	[self.mutableTestsByName setObject:test forKey:test.name];
}


-(NSArray *)tests {
	return self.mutableTests;
}

-(NSDictionary *)testsByName {
	return self.mutableTestsByName;
}


-(void)setStateClass:(Class)stateClass {
	NSAssert(stateClass != nil, @"No state class found for suite ‘%@’. Did you forget to add a @l3_suite_implementation for this suite? Did you add one but give it the wrong identifier?", self.name);
	_stateClass = stateClass;
}


#pragma mark Steps

-(void)addStep:(L3TestStep *)step {
	NSParameterAssert(step != nil);
	NSParameterAssert([self.steps objectForKey:step.name] == nil);
	
	[self.mutableSteps setObject:step forKey:step.name];
}


-(NSDictionary *)steps {
	return self.mutableSteps;
}


#pragma mark L3Test

-(bool)isComposite {
	return YES;
}


#pragma mark Visitors

@l3_test("visits its child tests lazily") {
	L3TestSuite *parent = [L3TestSuite testSuiteWithName:@"parent"];
	L3TestSuite *child = [L3TestSuite testSuiteWithName:@"child"];
	[parent addTest:child];
	[parent acceptVisitor:test];
	l3_assert(test.visitedTests, l3_equals(@[parent, child]));
}

-(void)acceptVisitor:(id<L3TestVisitor>)visitor inTestSuite:(L3TestSuite *)parentSuite {
	[visitor testSuite:self inTestSuite:parentSuite withChildren:^{
		for (id<L3Test> test in self.tests) {
			[test acceptVisitor:visitor inTestSuite:self];
		}
	}];
	
}

-(void)acceptVisitor:(id<L3TestVisitor>)visitor {
	[self acceptVisitor:visitor inTestSuite:nil];
}

@end


@l3_suite_implementation (L3TestSuite)

-(void)testCase:(L3TestCase *)testCase inTestSuite:(L3TestSuite *)suite {
	[self.visitedTests addObject:testCase];
}

-(void)testSuite:(L3TestSuite *)testSuite inTestSuite:(L3TestSuite *)suite withChildren:(void (^)())block {
	[self.visitedTests addObject:testSuite];
	
	block();
}

@end


NSString *L3MachOImagePathForAddress(void *address) {
	NSString *imagePath = nil;
	
	Dl_info info = {};
	if (dladdr(address, &info)) {
		imagePath = @(info.dli_fname);
	}
	
	return imagePath;
}

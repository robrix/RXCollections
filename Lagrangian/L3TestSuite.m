//  L3TestSuite.m
//  Created by Rob Rix on 2012-11-07.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestSuite.h"

@interface L3TestSuite ()

@property (strong, nonatomic) NSMutableArray *testCases;
@property (copy, nonatomic, readwrite) NSString *name;

@end

@implementation L3TestSuite

+(instancetype)suiteWithName:(NSString *)name {
	return [[self alloc] initWithName:name];
}

-(instancetype)initWithName:(NSString *)name {
	if ((self = [super init])) {
		_name = [name copy];
		_testCases = [NSMutableArray new];
	}
	return self;
}


-(void)addTestCase:(L3TestCase *)testCase {
//	[self.testCases addObject:testCase];
	NSLog(@"adding case to %@", self.name);
}

@end

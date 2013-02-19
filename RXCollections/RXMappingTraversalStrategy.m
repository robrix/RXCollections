//  RXMappingTraversalStrategy.m
//  Created by Rob Rix on 2013-02-19.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXMappingTraversalStrategy.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXMappingTraversalStrategy");

@implementation RXMappingTraversalStrategy

+(instancetype)strategyWithBlock:(id(^)(id))block {
	return [[self alloc] initWithBlock:block];
}

-(instancetype)initWithBlock:(id(^)(id))block {
	if ((self = [super init])) {
		_block = [block copy];
	}
	return self;
}


#pragma mark RXEnumerationTraversalStrategy

@l3_test("copies objects mapped using its block") {
	id internal[] = { @"rapid", @"deep", @"maximal" };
	__autoreleasing id external[16] = {};
	RXMappingTraversalStrategy *strategy = [RXMappingTraversalStrategy strategyWithBlock:^(NSString *each) {
		return [each stringByAppendingString:@"ly"];
	}];
	NSUInteger internalObjectsCount = sizeof internal / sizeof *internal;
	NSUInteger externalObjectsCount = sizeof external / sizeof *external;
	[strategy enumerateObjects:(__unsafe_unretained id *)(__unsafe_unretained id **)internal count:&internalObjectsCount intoObjects:external count:&externalObjectsCount];
	NSArray *actual = [NSArray arrayWithObjects:external count:externalObjectsCount];
	l3_assert(actual, l3_is(@[@"rapidly", @"deeply", @"maximally"]));
}

-(void)enumerateObjects:(in __unsafe_unretained id [])internalObjects count:(inout NSUInteger *)internalObjectsCount intoObjects:(out __autoreleasing id [])externalObjects count:(inout NSUInteger *)externalObjectsCount {
	NSUInteger count = MIN(*internalObjectsCount, *externalObjectsCount);
	for (NSUInteger i = 0; i < count; i++) {
		externalObjects[i] = self.block(internalObjects[i]);
	}
	*internalObjectsCount = *externalObjectsCount = count;
}

@end

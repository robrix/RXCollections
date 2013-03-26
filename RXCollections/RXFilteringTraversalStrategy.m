//  RXFilteringTraversalStrategy.m
//  Created by Rob Rix on 2013-02-19.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFilteringTraversalStrategy.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXFilteringTraversalStrategy");

@implementation RXFilteringTraversalStrategy

+(instancetype)strategyWithBlock:(RXFilterBlock)block {
	return [[self alloc] initWithBlock:block];
}

-(instancetype)initWithBlock:(RXFilterBlock)block {
	if ((self = [super init])) {
		_block = [block copy];
	}
	return self;
}


#pragma mark RXEnumerationTraversalStrategy

@l3_test("copies only those objects matching its block") {
	id internal[] = { @"pig", @"cat", @"fish", @"cow", @"wolf" };
	__autoreleasing id external[16] = {};
	RXFilteringTraversalStrategy *strategy = [RXFilteringTraversalStrategy strategyWithBlock:^bool(id each) {
		return [each hasPrefix:@"c"];
	}];
	NSUInteger internalCount = sizeof internal / sizeof *internal;
	NSUInteger externalCount = sizeof external / sizeof *external;
	[strategy enumerateObjects:(__unsafe_unretained id *)(__unsafe_unretained id **)internal count:&internalCount intoObjects:external count:&externalCount];
	NSArray *actual = [NSArray arrayWithObjects:external count:externalCount];
	l3_assert(internalCount, 5);
	l3_assert(externalCount, 2);
	l3_assert(actual, l3_is(@[@"cat", @"cow"]));
}

-(void)enumerateObjects:(in const id [])internalObjects count:(inout NSUInteger *)internalObjectsCount intoObjects:(out __autoreleasing id [])externalObjects count:(inout NSUInteger *)externalObjectsCount {
	NSUInteger producedCount = 0, consumedCount = 0;
	while (consumedCount < *internalObjectsCount && producedCount < *externalObjectsCount) {
		id object = internalObjects[consumedCount];
		if (self.block(object)) {
			externalObjects[producedCount] = object;
			producedCount++;
		}
		consumedCount++;
	}
	*internalObjectsCount = consumedCount;
	*externalObjectsCount = producedCount;
}

@end

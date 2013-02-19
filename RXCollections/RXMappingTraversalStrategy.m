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

@l3_test("maps objects using its block") {
	id internal[] = { @"rapid", @"deep", @"maximal" };
	__autoreleasing id external[16] = {};
	RXMappingTraversalStrategy *strategy = [RXMappingTraversalStrategy strategyWithBlock:^(NSString *each) {
		return [each stringByAppendingString:@"ly"];
	}];
	NSUInteger count = [strategy countByEnumeratingObjects:(__unsafe_unretained id *)(__unsafe_unretained id **)internal count:sizeof internal / sizeof *internal intoObjects:external count:sizeof external / sizeof *external];
	NSArray *actual = [NSArray arrayWithObjects:external count:count];
	l3_assert(actual, l3_is(@[@"rapidly", @"deeply", @"maximally"]));
}

-(NSUInteger)countByEnumeratingObjects:(in __unsafe_unretained id [])internalObjects count:(NSUInteger)internalObjectsCount intoObjects:(out __autoreleasing id [])externalObjects count:(NSUInteger)externalObjectsCount {
	NSUInteger count = MIN(internalObjectsCount, externalObjectsCount);
	for (NSUInteger i = 0; i < count; i++) {
		externalObjects[i] = self.block(internalObjects[i]);
	}
	return count;
}

@end

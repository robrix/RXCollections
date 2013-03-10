//  RXGeneratorTraversal.m
//  Created by Rob Rix on 2013-03-09.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXGeneratorTraversal.h"
#import "RXTuple.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXGeneratorTraversal");

@implementation RXGeneratorTraversal

#pragma mark Construction

+(instancetype)traversalWithGenerator:(RXGenerator)generator {
	return [[self alloc] initWithGenerator:generator];
}

-(instancetype)initWithGenerator:(RXGenerator)generator {
	if ((self = [super init])) {
		_generator = [generator copy];
	}
	return self;
}


#pragma mark NSFastEnumeration

static RXGenerator RXFibonacciSequenceGenerator() {
	__block RXTuple *tuple = [RXTuple tupleWithArray:@[@0, @1]];
	return [^{
		NSNumber *previous = tuple[1];
		NSUInteger next = [tuple[0] unsignedIntegerValue] + [previous unsignedIntegerValue];
		tuple = [RXTuple tupleWithArray:@[tuple[1], @(next)]];
		return previous;
	} copy];
}


@l3_test("enumerates generated objects") {
	NSMutableArray *series = [NSMutableArray new];
	for (NSNumber *number in [RXGeneratorTraversal traversalWithGenerator:RXFibonacciSequenceGenerator()]) {
		[series addObject:number];
		if (series.count == 12)
			break;
	}
	l3_assert(series, (@[@1, @1, @2, @3, @5, @8, @13, @21, @34, @55, @89, @144]));
}

-(NSUInteger)generateObjects:(__autoreleasing id [])objects count:(NSUInteger)count {
	for (NSUInteger i = 0; i < count; i++) {
		objects[i] = self.generator();
	}
	return count;
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	if (!state->state) {
		state->state = 1;
		state->mutationsPtr = state->extra;
	}
	
	NSUInteger count = [self generateObjects:(__autoreleasing id *)(void *)buffer count:len];
	
	state->itemsPtr = buffer;
	
	return count;
}

@end

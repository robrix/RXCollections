//  RXGeneratorTraversal.m
//  Created by Rob Rix on 2013-03-09.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFold.h"
#import "RXGeneratorTraversal.h"
#import "RXTuple.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXGeneratorTraversal");

typedef struct RXGeneratorTraversalState {
	unsigned long state;
	__unsafe_unretained id *items;
	unsigned long *mutations;
	__unsafe_unretained RXGenerator generator;
	unsigned long extra[4];
} RXGeneratorTraversalState;

@implementation RXGeneratorTraversal

#pragma mark Construction

+(instancetype)traversalWithGeneratorProvider:(RXGeneratorProvider)provider {
	return [[self alloc] initWithGeneratorProvider:provider];
}

-(instancetype)initWithGeneratorProvider:(RXGeneratorProvider)provider {
	if ((self = [super init])) {
		_provider = [provider copy];
	}
	return self;
}


#pragma mark NSFastEnumeration

static RXGenerator RXFibonacciSequenceGenerator() {
	__block RXTuple *tuple = [RXTuple tupleWithArray:@[@0, @1]];
	return [^(bool *stop) {
		NSNumber *previous = tuple[1], *next = @([tuple[0] unsignedIntegerValue] + [previous unsignedIntegerValue]);
		tuple = [RXTuple tupleWithArray:@[previous, next]];
		return previous;
	} copy];
}

@l3_test("enumerates generated objects") {
	NSMutableArray *series = [NSMutableArray new];
	for (NSNumber *number in [RXGeneratorTraversal traversalWithGeneratorProvider:^{ return RXFibonacciSequenceGenerator(); }]) {
		[series addObject:number];
		if (series.count == 12)
			break;
	}
	l3_assert(series, (@[@1, @1, @2, @3, @5, @8, @13, @21, @34, @55, @89, @144]));
}

static RXGenerator RXIntegerGenerator(NSUInteger n) {
	__block NSUInteger current = 0;
	return [^(bool *stop) {
		current++;
		if (current == n)
			*stop = YES;
		return @(current);
	} copy];
}

@l3_test("stops enumerating when requested to by the generator") {
	NSArray *integers = RXConstructArray([RXGeneratorTraversal traversalWithGeneratorProvider:^{ return RXIntegerGenerator(3); }]);
	l3_assert(integers, (@[@0, @1, @2, @3]));
}

-(NSUInteger)populateObjects:(__autoreleasing id [])objects count:(NSUInteger)count generator:(RXGenerator)generator {
	bool stop = NO;
	for (NSUInteger i = 0; i < count; i++) {
		objects[i] = generator(&stop);
		if (stop)
			break;
	}
	return count;
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)fastEnumerationState objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	RXGeneratorTraversalState *state = (RXGeneratorTraversalState *)fastEnumerationState;
	__strong RXGenerator *generator = (__strong RXGenerator *)(void *)&(state->generator);
	if (!state->state) {
		state->state = 1;
		state->mutations = state->extra;
		*generator = self.provider();
	}
	
	NSUInteger count = [self populateObjects:(__autoreleasing id *)(void *)buffer count:len generator:*generator];
	
	state->items = buffer;
	
	return count;
}

@end

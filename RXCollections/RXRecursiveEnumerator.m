//  RXRecursiveEnumerator.m
//  Created by Rob Rix on 2013-01-11.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXRecursiveEnumerator.h"
#import "RXFold.h"
#import "RXPair.h"

#import <Lagrangian/Lagrangian.h>


@l3_suite("RXRecursiveEnumerator");

static void RXAccumulateRecursiveContentsOfTarget(NSMutableArray *accumulator, id target, NSString *keyPath);

@implementation RXRecursiveEnumerator

+(instancetype)enumeratorWithTarget:(id)target keyPath:(NSString *)keyPath {
	return [[self alloc] initWithTarget:target keyPath:keyPath];
}

-(instancetype)initWithTarget:(id)target keyPath:(NSString *)keyPath {
	if ((self = [super init])) {
		_target = target;
		_keyPath = [keyPath copy];
	}
	return self;
}


@l3_test("accumulates the contents of homogeneous trees in depth-first order") {
	RXTuple *tree = [RXTuple tupleWithLeft:[RXTuple tupleWithLeft:@"x" right:[RXTuple tupleWithLeft:@"y" right:@"z"]] right:@"w"];
	NSMutableArray *flattened = [NSMutableArray new];
	RXAccumulateRecursiveContentsOfTarget(flattened, tree, @"allObjects");
	l3_assert(flattened, l3_equals(@[tree, tree.left, [tree.left left], [tree.left right], [[tree.left right] left], [[tree.left right] right], tree.right]));
}

static void RXAccumulateRecursiveContentsOfTarget(NSMutableArray *accumulator, id target, NSString *keyPath) {
	[accumulator addObject:target];
	if ([target respondsToSelector:NSSelectorFromString(keyPath)]) {
		for (id element in [target valueForKeyPath:keyPath]) {
			RXAccumulateRecursiveContentsOfTarget(accumulator, element, keyPath);
		}
	}
}


@l3_test("recursively enumerates trees in depth-first order") {
	RXTuple *tree = [RXTuple tupleWithLeft:[RXTuple tupleWithLeft:@"x" right:[RXTuple tupleWithLeft:@"y" right:@"z"]] right:@"w"];
	l3_assert(RXFold([RXRecursiveEnumerator enumeratorWithTarget:tree keyPath:@"allObjects"], @"", ^(NSString *memo, id each) {
		return [memo stringByAppendingString:[each isKindOfClass:[NSString class]]? each : @""];
	}), @"xyzw");
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	NSMutableArray *flattened = nil;
	if (state->state == 0) {
		// fixme: this is not guaranteed to release the thing
		state->mutationsPtr = (__bridge_retained void *)(flattened = [NSMutableArray new]);
		RXAccumulateRecursiveContentsOfTarget(flattened, self.target, self.keyPath);
	} else {
		flattened = (__bridge NSMutableArray *)(void *)state->mutationsPtr;
	}
	
	NSUInteger count = 0;
	if (state->state < flattened.count) {
		
		state->itemsPtr = buffer;
		while ((state->state < flattened.count) && (count < len)) {
			buffer[count] = flattened[state->state];
			state->state++;
			count++;
		}
	}
	
	if (count == 0) {
		NSMutableArray *stuff = (__bridge_transfer NSMutableArray *)(void *)state->mutationsPtr;
		[stuff self];
	}
	
	return count;
}

@end

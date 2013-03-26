//  RXRecursiveEnumerator.m
//  Created by Rob Rix on 2013-01-11.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFastEnumerationState.h"
#import "RXFold.h"
#import "RXPair.h"
#import "RXRecursiveEnumerator.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXRecursiveEnumerator");

static void RXAccumulateRecursiveContentsOfTarget(NSMutableArray *accumulator, id target, NSString *keyPath);

@interface RXRecursiveEnumeratorState : RXFastEnumerationState

+(id<RXFastEnumerationState>)stateWithNSFastEnumerationState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)count recursiveEnumerator:(RXRecursiveEnumerator *)enumerator NS_RETURNS_RETAINED;

@property (nonatomic, strong) NSMutableArray *flattened;
@property (nonatomic, assign) NSUInteger currentIndex;

@end

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
	RXRecursiveEnumeratorState *enumeratorState = [RXRecursiveEnumeratorState stateWithNSFastEnumerationState:state objects:buffer count:len recursiveEnumerator:self];
	
	NSMutableArray *flattened = enumeratorState.flattened;
	
	NSUInteger count = 0;
	if (enumeratorState.currentIndex < flattened.count) {
		while ((enumeratorState.currentIndex < flattened.count) && (count < len)) {
			buffer[count] = flattened[enumeratorState.currentIndex];
			enumeratorState.currentIndex++;
			count++;
		}
	}
	
	return count;
}

@end

@implementation RXRecursiveEnumeratorState {
	__unsafe_unretained NSMutableArray *_flattened;
	NSUInteger _currentIndex;
}

+(id<RXFastEnumerationState>)stateWithNSFastEnumerationState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)count recursiveEnumerator:(RXRecursiveEnumerator *)enumerator NS_RETURNS_RETAINED {
	return [self stateWithNSFastEnumerationState:state objects:buffer count:count initializationHandler:^(RXRecursiveEnumeratorState *state) {
		state.flattened = [NSMutableArray new];
		RXAccumulateRecursiveContentsOfTarget(state.flattened, enumerator.target, enumerator.keyPath);
	}];
}


-(NSMutableArray *)flattened {
	return _flattened;
}

-(void)setFlattened:(NSMutableArray *)flattened {
	__autoreleasing NSMutableArray *autoreleasingFlattened = flattened;
	_flattened = autoreleasingFlattened;
}

@end

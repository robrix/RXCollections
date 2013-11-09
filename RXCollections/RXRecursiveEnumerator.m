//  RXRecursiveEnumerator.m
//  Created by Rob Rix on 2013-01-11.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFold.h"
#import "RXPair.h"
#import "RXRecursiveEnumerator.h"

#import <Lagrangian/Lagrangian.h>

L3_OVERLOADABLE L3Test *L3TestDefine(NSString *file, NSUInteger line, void(*subject)(NSMutableArray *, id, NSString *), L3TestBlock block) {
	return [L3Test testWithSourceReference:L3SourceReferenceCreate(nil, file, line, nil, L3TestSymbolForFunction((L3FunctionTestSubject)subject)) block:block];
}

static void RXAccumulateRecursiveContentsOfTarget(NSMutableArray *accumulator, id target, NSString *keyPath);

@interface RXRecursiveEnumerator ()
@property (nonatomic, copy) NSArray *flattened;
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

l3_test(&RXAccumulateRecursiveContentsOfTarget, ^{
	RXTuple *tree = [RXTuple tupleWithLeft:[RXTuple tupleWithLeft:@"x" right:[RXTuple tupleWithLeft:@"y" right:@"z"]] right:@"w"];
	NSMutableArray *flattened = [NSMutableArray new];
	RXAccumulateRecursiveContentsOfTarget(flattened, tree, @"allObjects");
	l3_expect(flattened).to.equal(@[tree, tree.left, [tree.left left], [tree.left right], [[tree.left right] left], [[tree.left right] right], tree.right]);
})

static void RXAccumulateRecursiveContentsOfTarget(NSMutableArray *accumulator, id target, NSString *keyPath) {
	[accumulator addObject:target];
	if ([target respondsToSelector:NSSelectorFromString(keyPath)]) {
		for (id element in [target valueForKeyPath:keyPath]) {
			RXAccumulateRecursiveContentsOfTarget(accumulator, element, keyPath);
		}
	}
}

-(NSArray *)flattened {
	if (!_flattened) {
		NSMutableArray *flattened = [NSMutableArray new];
		RXAccumulateRecursiveContentsOfTarget(flattened, self.target, self.keyPath);
		self.flattened = flattened;
	}
	return _flattened;
}


l3_test(@selector(countByEnumeratingWithState:objects:count:), ^{
	RXTuple *tree = [RXTuple tupleWithLeft:[RXTuple tupleWithLeft:@"x" right:[RXTuple tupleWithLeft:@"y" right:@"z"]] right:@"w"];
	id folded = RXFold([RXRecursiveEnumerator enumeratorWithTarget:tree keyPath:@"allObjects"], @"", ^(NSString *memo, id each, bool *stop) {
		return [memo stringByAppendingString:[each isKindOfClass:[NSString class]]? each : @""];
	});
	l3_expect(folded).to.equal(@"xyzw");
})

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	NSArray *flattened = self.flattened;
	
	NSUInteger count = 0;
	if (state->state < flattened.count) {
		state->itemsPtr = buffer;
		state->mutationsPtr = state->extra;
		while ((state->state < flattened.count) && (count < len)) {
			buffer[count] = flattened[state->state];
			state->state++;
			count++;
		}
	}
	
	return count;
}

@end

//  RXGenerator.m
//  Created by Rob Rix on 2013-03-09.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFold.h"
#import "RXGenerator.h"
#import "RXTuple.h"
#import "RXFastEnumerationState.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXGenerator");

typedef NS_ENUM(unsigned long, RXGeneratorTraversalCurrentState) {
	RXGeneratorTraversalCurrentStatePending = 0,
	RXGeneratorTraversalCurrentStateActive = 1,
	RXGeneratorTraversalCurrentStateComplete = 2,
};

@interface RXGeneratorEnumerationState : RXFastEnumerationState

+(instancetype)stateWithNSFastEnumerationState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)count generator:(RXGenerator *)generator NS_RETURNS_RETAINED;

@property (nonatomic, assign) RXGeneratorTraversalCurrentState state;
@property (nonatomic, copy) id<NSCopying> context;
@property (nonatomic, readonly) __autoreleasing id<NSCopying> *contextReference;
@property (nonatomic, copy) RXGeneratorBlock generatorBlock;

@end


@implementation RXGenerator

#pragma mark Construction

+(instancetype)generatorWithBlock:(RXGeneratorBlock)block {
	return [self generatorWithContext:nil block:block];
}

+(instancetype)generatorWithContext:(id<NSCopying>)context block:(RXGeneratorBlock)block {
	return [[self alloc] initWithContext:context block:block];
}

-(instancetype)initWithContext:(id<NSCopying>)context block:(RXGeneratorBlock)block {
	if ((self = [super init])) {
		_context = context;
		_block = [block copy];
	}
	return self;
}


#pragma mark NSFastEnumeration

static RXGeneratorBlock RXFibonacciGenerator() {
	return [^(RXTuple **tuple, bool *stop) {
		NSNumber *previous = (*tuple)[1], *next = @([(*tuple)[0] unsignedIntegerValue] + [previous unsignedIntegerValue]);
		*tuple = [RXTuple tupleWithArray:@[previous, next]];
		return previous;
	} copy];
}

@l3_test("enumerates generated objects") {
	NSMutableArray *series = [NSMutableArray new];
	for (NSNumber *number in [RXGenerator generatorWithContext:[RXTuple tupleWithArray:@[@0, @1]] block:RXFibonacciGenerator()]) {
		[series addObject:number];
		if (series.count == 12)
			break;
	}
	l3_assert(series, (@[@1, @1, @2, @3, @5, @8, @13, @21, @34, @55, @89, @144]));
}

static RXGeneratorBlock RXIntegerGenerator(NSUInteger n) {
	return [^(NSNumber **context, bool *stop) {
		NSUInteger current = (*context).unsignedIntegerValue;
		*context = @(current + 1);
		if (current >= n)
			*stop = YES;
		return @(current);
	} copy];
}

@l3_test("stops enumerating when requested to by the generator") {
	NSArray *integers = RXConstructArray([RXGenerator generatorWithBlock:RXIntegerGenerator(3)]);
	l3_assert(integers, (@[@0, @1, @2, @3]));
}

-(NSUInteger)populateCountObjects:(NSUInteger)count intoState:(RXGeneratorEnumerationState *)state {
	bool stop = NO;
	NSUInteger i = 0;
	while ((i < count) && !stop) {
		state.items[i++] = state.generatorBlock(state.contextReference, &stop);
	}
	if ((stop == YES) || (i == 0))
		state.state = RXGeneratorTraversalCurrentStateComplete;
	return i;
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)fastEnumerationState objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	RXGeneratorEnumerationState *state = [RXGeneratorEnumerationState stateWithNSFastEnumerationState:fastEnumerationState objects:buffer count:len generator:self];
	
	return (state.state != RXGeneratorTraversalCurrentStateComplete)?
		[self populateCountObjects:len intoState:state]
	:	0;
}

@end


@implementation RXGeneratorEnumerationState {
	RXGeneratorTraversalCurrentState _state;
	__unsafe_unretained id<NSCopying> _context;
	__unsafe_unretained RXGeneratorBlock _generatorBlock;
}

+(instancetype)stateWithNSFastEnumerationState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)count generator:(RXGenerator *)generator NS_RETURNS_RETAINED {
	return [self stateWithNSFastEnumerationState:state objects:buffer count:count initializationHandler:^(RXGeneratorEnumerationState *state) {
		state.state = RXGeneratorTraversalCurrentStateActive;
		state.context = generator.context;
		state.generatorBlock = generator.block;
	}];
}

-(id<NSCopying>)context {
	return _context;
}

-(void)setContext:(id<NSCopying>)context {
	__autoreleasing id<NSCopying> temporaryContext = [context copyWithZone:NULL];
	_context = temporaryContext;
}

-(__autoreleasing id<NSCopying> *)contextReference {
	return (__autoreleasing id *)(void *)&_context;
}


-(RXGeneratorBlock)generatorBlock {
	return _generatorBlock;
}

-(void)setGeneratorBlock:(RXGeneratorBlock)generatorBlock {
	__autoreleasing RXGeneratorBlock temporaryGeneratorBlock = [generatorBlock copy];
	_generatorBlock = temporaryGeneratorBlock;
}

@end

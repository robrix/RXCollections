//  RXEnumerationTraversal.m
//  Created by Rob Rix on 2013-02-11.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXEnumerationTraversal.h"
#import "RXIdentityTraversalStrategy.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXEnumerationTraversal");

typedef struct RXEnumerationTraversalState {
	unsigned long iterationCount;
	__unsafe_unretained id *items;
	unsigned long *mutations;
	NSFastEnumerationState *internalState;
	__unsafe_unretained id *internalObjects;
	unsigned long internalObjectsCount;
	unsigned long extra[2];
} RXEnumerationTraversalState;

@implementation RXEnumerationTraversal

+(instancetype)traversalWithEnumeration:(id<NSFastEnumeration>)enumeration strategy:(id<RXEnumerationTraversalStrategy>)strategy; {
	return [[self alloc] initWithEnumeration:enumeration strategy:strategy];
}

-(instancetype)initWithEnumeration:(id<NSFastEnumeration>)enumeration strategy:(id<RXEnumerationTraversalStrategy>)strategy {
	NSParameterAssert(enumeration != nil);
	NSParameterAssert(strategy != nil);
	
	if ((self = [super init])) {
		_enumeration = enumeration;
		_strategy = strategy;
	}
	return self;
}


#pragma mark RXTraversal

@l3_test("maps with reentrancy over collections of more items than the for(in) buffer") {
	NSArray *alphabet = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z"];
	id<NSFastEnumeration> toUpper = [RXEnumerationTraversal traversalWithEnumeration:alphabet strategy:[RXIdentityTraversalStrategy new]];
	
	NSMutableArray *combos = [NSMutableArray new];
	// the following autorelease pools are convenient to test the correct handling of autoreleased temporaries; they are not particularly useful or interesting otherwise, and are certainly not necessary for use of the API
	@autoreleasepool {
		for (NSString *first in toUpper) {
			@autoreleasepool {
				for (NSString *second in toUpper) {
					@autoreleasepool {
						[combos addObject:[first stringByAppendingString:second]];
					}
				}
			}
		}
	}
	
	l3_assert(combos.count, alphabet.count * alphabet.count);
}

@l3_test("sanity check: unsigned long is sufficient to store a pointer") {
	l3_assert(sizeof(unsigned long), sizeof(NSFastEnumerationState *));
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)fastEnumerationState objects:(__unsafe_unretained id [])externalObjects count:(NSUInteger)externalObjectsCount {
	RXEnumerationTraversalState *state = (RXEnumerationTraversalState *)fastEnumerationState;
	
	if (!state->internalState) {
		// this allows the internal state to be persisted for the duration of the current enumeration, without having it extend past the end in the event of early termination (e.g. a break in a for(in) loop).
		// we require callers to ensure that they do not drain the external autorelease pool between calls using the same fastEnumerationState pointer.
		// this is the case for for(in), and is believed to be a reasonable requirement for other well-designed callers.
		__autoreleasing NSMutableData *internalStateData = [NSMutableData dataWithLength:sizeof *state->internalState];
		state->internalState = internalStateData.mutableBytes;
	}
	NSFastEnumerationState *internalState = state->internalState;
	
	if (state->internalObjectsCount == 0) {
		// if we processed all the remaining objects on our last call, then we need to get the next batch
		state->internalObjectsCount = [self.enumeration countByEnumeratingWithState:internalState objects:externalObjects count:externalObjectsCount];
		
		// externalize the mutations of our internal enumeration, allowing for(in) (or other interested callers) to correctly assert that our internal enumeration has not changed while it is being iterated.
		// additionally, for(in) requires that this be a valid pointer; it dereferences it without checking.
		state->mutations = internalState->mutationsPtr;
		
		// our marker for iterating through the internal items
		state->internalObjects = internalState->itemsPtr;
	}
	
	// for(in) requires that we store some non-zero value to this field.
	// counting the calls to this method may be useful for debugging.
	state->iterationCount++;
	
	unsigned long count = [self.strategy countByEnumeratingObjects:state->internalObjects count:state->internalObjectsCount intoObjects:(__autoreleasing id *)(void *)externalObjects count:externalObjectsCount];
	
	// adjust our references based on what we have 
	state->internalObjects += count;
	state->internalObjectsCount -= count;
	
	// we always return results in the buffer given to us by the caller.
	state->items = externalObjects;
	
	return count;
}

@end

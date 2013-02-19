//  RXMappingTraversal.m
//  Created by Rob Rix on 2013-02-11.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXMappingTraversal.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXMappingTraversal");

typedef struct RXMappingTraversalState {
	unsigned long iterationCount;
	__unsafe_unretained id *items;
	unsigned long *mutations;
	NSFastEnumerationState *internalState;
	__unsafe_unretained id *internalObjects;
	unsigned long internalObjectsCount;
	unsigned long extra[2];
} RXMappingTraversalState;

@implementation RXMappingTraversal

+(instancetype)traversalWithEnumeration:(id<NSFastEnumeration>)enumeration block:(id(^)(id))block {
	return [[self alloc] initWithEnumeration:enumeration block:block];
}

-(instancetype)initWithEnumeration:(id<NSFastEnumeration>)enumeration block:(id(^)(id))block {
	NSParameterAssert(enumeration != nil);
	NSParameterAssert(block != nil);
	
	if ((self = [super init])) {
		_enumeration = enumeration;
		_block = [block copy];
	}
	return self;
}


#pragma mark NSFastEnumeration

@l3_test("maps while it is enumerated") {
	NSArray *adjectives = @[@"quick", @"pointed"];
	NSMutableArray *adverbs = [NSMutableArray new];
	
	for (NSString *adverb in [RXMappingTraversal traversalWithEnumeration:adjectives block:^(NSString *adjective) {
		return [adjective stringByAppendingString:@"ly"];
	}]) {
		[adverbs addObject:adverb];
	}
	l3_assert(adverbs, l3_is(@[@"quickly", @"pointedly"]));
}

@l3_test("maps with reentrancy over collections of more items than the for(in) buffer") {
	NSArray *alphabet = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z"];
	id<NSFastEnumeration> toUpper = [RXMappingTraversal traversalWithEnumeration:alphabet block:^(NSString *letter) {
		return [letter uppercaseString];
	}];
	
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

-(NSUInteger)countByEnumeratingObjects:(in __unsafe_unretained id [])internalObjects count:(NSUInteger)internalObjectsCount intoObjects:(out __autoreleasing id [])externalObjects count:(NSUInteger)externalObjectsCount {
	NSUInteger count = MIN(internalObjectsCount, externalObjectsCount);
	for (NSUInteger i = 0; i < count; i++) {
		externalObjects[i] = self.block(internalObjects[i]);
	}
	return count;
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)fastEnumerationState objects:(__unsafe_unretained id [])externalObjects count:(NSUInteger)externalObjectsCount {
	RXMappingTraversalState *state = (RXMappingTraversalState *)fastEnumerationState;
	
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
	
	unsigned long count = [self countByEnumeratingObjects:state->internalObjects count:state->internalObjectsCount intoObjects:(__autoreleasing id *)(void *)externalObjects count:externalObjectsCount];
	
	// adjust our references based on what we have 
	state->internalObjects += count;
	state->internalObjectsCount -= count;
	
	// we always return results in the buffer given to us by the caller.
	state->items = externalObjects;
	
	return count;
}

@end

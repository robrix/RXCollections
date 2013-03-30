//  RXEnumerationTraversal.m
//  Created by Rob Rix on 2013-02-11.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXEnumerationTraversal.h"
#import "RXFastEnumerationState.h"
#import "RXFilteringTraversalStrategy.h"
#import "RXIdentityTraversalStrategy.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXEnumerationTraversal");

@interface RXEnumerationTraversalState : RXFastEnumerationState

+(id<RXFastEnumerationState>)stateWithNSFastEnumerationState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)count NS_RETURNS_RETAINED;

@property (nonatomic, strong) id<RXFastEnumerationState> internalState;
@property (nonatomic, assign) __autoreleasing id *internalObjects;
@property (nonatomic, assign) unsigned long internalObjectsCount;

@end

@l3_set_up {
	test[@"alphabet"] = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z"];
}

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
	NSArray *alphabet = test[@"alphabet"];
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

@l3_test("reapplies its strategy when it consumes but does not produce") {
	NSFastEnumerationState state = {};
	__block NSUInteger timesCalled = 0;
	RXEnumerationTraversal *traversal = [RXEnumerationTraversal traversalWithEnumeration:test[@"alphabet"] strategy:[RXFilteringTraversalStrategy strategyWithBlock:^bool(id x) {
		timesCalled++;
		return NO;
	}]];
	__unsafe_unretained id objects[4] = {};
	NSUInteger count = [traversal countByEnumeratingWithState:&state objects:objects count:sizeof objects / sizeof *objects];
	l3_assert(count, 0);
	l3_assert(timesCalled, 26);
}

@l3_test("sanity check: unsigned long is sufficient to store a pointer") {
	l3_assert(sizeof(unsigned long), sizeof(NSFastEnumerationState *));
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)fastEnumerationState objects:(__unsafe_unretained id [])externalObjects count:(NSUInteger)externalObjectsCount {
	RXEnumerationTraversalState *state = [RXEnumerationTraversalState stateWithNSFastEnumerationState:fastEnumerationState objects:externalObjects count:externalObjectsCount];
	RXFastEnumerationState *internalState = state.internalState;
	
	if (state.internalObjectsCount == 0) {
		// if this is the first iteration or if we processed all our objects on our previous iteration, then we need to get the next batch of objects, if any
		state.internalObjectsCount = [self.enumeration countByEnumeratingWithState:internalState.NSFastEnumerationState objects:externalObjects count:externalObjectsCount];
		
		// externalize the mutations of our internal enumeration, allowing for(in) (or other interested callers) to correctly assert that our internal enumeration has not changed while it is being iterated.
		// additionally, for(in) requires that this be a valid pointer; it dereferences it without checking.
		state.mutations = internalState.mutations;
		
		// our marker for iterating through the internal items
		state.internalObjects = internalState.items;
	}
	
	NSUInteger consumedCount = state.internalObjectsCount;
	NSUInteger producedCount = 0;
	while (consumedCount > 0 && producedCount == 0) {
		consumedCount = state.internalObjectsCount;
		producedCount = externalObjectsCount;
		[self.strategy enumerateObjects:state.internalObjects count:&consumedCount intoObjects:state.items count:&producedCount];
		
		// adjust the internal objects pointer and count based on how many internal objects we consumed
		state.internalObjects += consumedCount;
		state.internalObjectsCount -= consumedCount;
	}
	
	return producedCount;
}

@end

@implementation RXEnumerationTraversalState

+(id<RXFastEnumerationState>)stateWithNSFastEnumerationState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)count NS_RETURNS_RETAINED {
	return [super stateWithNSFastEnumerationState:state objects:buffer count:count initializationHandler:^(RXEnumerationTraversalState *state) {
		state.internalState = [RXHeapFastEnumerationState state];
	}];
}

@end

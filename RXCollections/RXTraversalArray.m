//  RXTraversalArray.m
//  Created by Rob Rix on 2013-03-03.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXTraversalArray.h"
#import "RXIntervalTraversal.h"
#import <Lagrangian/Lagrangian.h>

@l3_suite("RXTraversalArray");

@l3_set_up {
	test[@"items"] = [RXIntervalTraversal traversalWithInterval:RXIntervalMake(0, 63)];
	test[@"array"] = [RXTraversalArray arrayWithTraversal:test[@"items"]];
}

typedef struct RXTraversalArrayEnumerationState {
	unsigned long iterationCount;
	__unsafe_unretained id *items;
	unsigned long *mutations;
	unsigned long enumeratedObjectsCount;
	unsigned long extra[4];
} RXTraversalArrayEnumerationState;

@interface RXTraversalArray ()

@property (nonatomic, strong) id<RXTraversal> enumeration;
@property (nonatomic, assign) NSUInteger internalCount;
@property (nonatomic, assign) NSUInteger enumeratedCount;
@property (nonatomic, assign) NSUInteger processedCount;
@property (nonatomic, assign, readonly) NSFastEnumerationState state;
@property (nonatomic, strong) NSMutableArray *enumeratedObjects;

@end

@implementation RXTraversalArray

#pragma mark Construction

+(instancetype)arrayWithTraversal:(id<RXTraversal>)traversal count:(NSUInteger)count {
	return [[self alloc] initWithTraversal:traversal count:count];
}

+(instancetype)arrayWithTraversal:(id<RXTraversal>)traversal {
	return [self arrayWithTraversal:traversal count:RXTraversalUnknownCount];
}

-(instancetype)initWithTraversal:(id<RXTraversal>)traversal count:(NSUInteger)count {
	if ((self = [super init])) {
		_enumeration = traversal;
		if ((count == RXTraversalUnknownCount) && ([traversal respondsToSelector:@selector(count)]))
			_internalCount = [(id<RXFiniteTraversal>)traversal count];
		else
			_internalCount = count;
	}
	return self;
}


#pragma mark NSArray primitives

@l3_test("count can be passed in to avoid traversing the entire enumeration") {
	RXTraversalArray *array = [RXTraversalArray arrayWithTraversal:test[@"items"] count:[test[@"items"] count]];
	[array count];
	l3_assert(array.enumeratedObjects, nil);
}

@l3_test("if count is inferred, it must traverse the entire enumeration") {
	RXTraversalArray *array = test[@"array"];
	[array count];
	l3_assert(array.enumeratedObjects.count, 64);
}

-(NSUInteger)count {
	if (self.internalCount == RXTraversalUnknownCount)
		[self populateUpToIndex:NSUIntegerMax];
	return self.internalCount;
}

@l3_test("enumerates until it gets the index required") {
	RXTraversalArray *array = test[@"array"];
	[array objectAtIndex:0];
	l3_assert(array.enumeratedObjects.count, 16);
	[array objectAtIndex:15];
	l3_assert(array.enumeratedObjects.count, 16);
	[array objectAtIndex:16];
	l3_assert(array.enumeratedObjects.count, 32);
}

-(id)objectAtIndex:(NSUInteger)index {
	[self populateUpToIndex:index];
	return self.enumeratedObjects[index];
}


#pragma mark Populating

@l3_test("nils out its enumeration when it has been exhausted") {
	RXTraversalArray *array = test[@"array"];
	[array populateUpToIndex:NSUIntegerMax];
	l3_assert(array.enumeration, nil);
}

-(void)populateUpToIndex:(NSUInteger)index {
	if (!self.enumeration || self.enumeratedObjects.count > index)
		return;
	
	if (!self.enumeratedObjects)
		self.enumeratedObjects = [NSMutableArray new];
	
	__unsafe_unretained id objects[16];
	const NSUInteger kChunkCount = sizeof objects / sizeof *objects;
	while (self.enumeratedObjects.count <= index) {
		if (self.processedCount == self.enumeratedCount) {
			self.processedCount = 0;
			self.enumeratedCount = [self.enumeration countByEnumeratingWithState:&_state objects:objects count:kChunkCount];
			if (self.enumeratedCount == 0) {
				self.internalCount = self.enumeratedObjects.count;
				self.enumeration = nil;
				break;
			}
		}
		
		NSUInteger count = MIN(self.enumeratedCount, (index == RXTraversalUnknownCount)? NSUIntegerMax : (ceil((index + 1) / (CGFloat)kChunkCount) * kChunkCount));
		
		for (NSUInteger i = 0; i < count; i++) {
			[self.enumeratedObjects addObject:self.state.itemsPtr[i + self.processedCount]];
		}
		
		self.processedCount += count;
	}
}


#pragma mark NSFastEnumeration

@l3_test("implements NSFastEnumeration by lazily populating its array") {
	RXTraversalArray *array = test[@"array"];
	for (id x in array) { break; }
	l3_assert(array.enumeratedObjects.count, 16);
	for (id x in array) { break; }
	l3_assert(array.enumeratedObjects.count, 16);
	for (id x in array) {}
	l3_assert(array.enumeratedObjects.count, 64);
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)enumerationState objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	RXTraversalArrayEnumerationState *state = (RXTraversalArrayEnumerationState *)enumerationState;
	state->iterationCount++;
	
	NSUInteger count = 0;
	if (state->enumeratedObjectsCount != self.internalCount) {
		[self populateUpToIndex:state->enumeratedObjectsCount + len - 1];
		if (self.enumeration)
			state->mutations = self.state.mutationsPtr;
		else
			state->mutations = state->extra;
		
		count = MIN(len, self.enumeratedObjects.count - state->enumeratedObjectsCount);
		[self.enumeratedObjects getObjects:buffer range:NSMakeRange(state->enumeratedObjectsCount, count)];
		state->enumeratedObjectsCount += count;
		state->items = buffer;
	}
	
	return count;
}

@end

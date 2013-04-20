//  RXEnumerationArray.m
//  Created by Rob Rix on 2013-03-03.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXInterval.h"
#import "RXEnumerationArray.h"
#import "RXTraversal.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXEnumerationArray");

@l3_set_up {
	test[@"items"] = RXInterval(0, 63).traversal;
	test[@"array"] = [RXEnumerationArray arrayWithEnumeration:test[@"items"]];
}

@interface RXEnumerationArray ()

@property (nonatomic, strong) id<NSObject, NSFastEnumeration> enumeration;
@property (nonatomic, assign) NSUInteger internalCount;
@property (nonatomic, assign) NSUInteger enumeratedCount;
@property (nonatomic, assign) NSUInteger processedCount;
@property (nonatomic, assign, readonly) NSFastEnumerationState state;
@property (nonatomic, strong) NSMutableArray *enumeratedObjects;

@end

@implementation RXEnumerationArray

#pragma mark Construction

+(instancetype)arrayWithEnumeration:(id<NSObject, NSFastEnumeration>)traversal count:(NSUInteger)count {
	return [[self alloc] initWithEnumeration:traversal count:count];
}

+(instancetype)arrayWithEnumeration:(id<NSObject, NSFastEnumeration>)traversal {
	return [self arrayWithEnumeration:traversal count:RXTraversalUnknownCount];
}

-(instancetype)initWithEnumeration:(id<NSObject, NSFastEnumeration>)traversal count:(NSUInteger)count {
	if ((self = [super init])) {
		_enumeration = traversal;
		if ((count == RXTraversalUnknownCount) && ([traversal conformsToProtocol:@protocol(RXFiniteTraversal)]))
			_internalCount = [(id<RXFiniteTraversal>)traversal count];
		else
			_internalCount = count;
	}
	return self;
}


#pragma mark NSArray primitives

@l3_test("count can be passed in to avoid traversing the entire enumeration") {
	RXEnumerationArray *array = [RXEnumerationArray arrayWithEnumeration:test[@"items"] count:[test[@"items"] count]];
	[array count];
	l3_assert(array.enumeratedObjects, nil);
}

@l3_test("if count is inferred, it must traverse the entire enumeration") {
	RXEnumerationArray *array = [RXEnumerationArray arrayWithEnumeration:[@[@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11, @12, @13, @14, @15, @16, @17, @18, @19, @20, @21, @22, @23, @24, @25, @26, @27, @28, @29, @30, @31, @32, @33, @34, @35, @36, @37, @38, @39, @40, @41, @42, @43, @44, @45, @46, @47, @48, @49, @50, @51, @52, @53, @54, @55, @56, @57, @58, @59, @60, @61, @62, @63] objectEnumerator]];
	[array count];
	l3_assert(array.enumeratedObjects.count, 64);
}

-(NSUInteger)count {
	if (self.internalCount == RXTraversalUnknownCount)
		[self populateUpToIndex:NSUIntegerMax];
	return self.internalCount;
}

@l3_test("enumerates until it gets the index required") {
	RXEnumerationArray *array = test[@"array"];
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
	RXEnumerationArray *array = test[@"array"];
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
		
		NSUInteger count = MIN(self.enumeratedCount, (index == RXTraversalUnknownCount)? NSUIntegerMax : (ceil((index + 1) / (double)kChunkCount) * kChunkCount));
		
		for (NSUInteger i = 0; i < count; i++) {
			[self.enumeratedObjects addObject:self.state.itemsPtr[i + self.processedCount]];
		}
		
		self.processedCount += count;
	}
}


#pragma mark NSFastEnumeration

@l3_test("implements NSFastEnumeration by lazily populating its array") {
	RXEnumerationArray *array = test[@"array"];
	for (id x in array) { break; }
	l3_assert(array.enumeratedObjects.count, 16);
	for (id x in array) { break; }
	l3_assert(array.enumeratedObjects.count, 16);
	for (id x in array) {}
	l3_assert(array.enumeratedObjects.count, 64);
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	NSUInteger count = 0;
	if (state->state != self.internalCount) {
		state->itemsPtr = buffer;
		
		[self populateUpToIndex:state->state + len - 1];
		if (self.enumeration)
			state->mutationsPtr = self.state.mutationsPtr;
		else
			state->mutationsPtr = state->extra;
		
		count = MIN(len, self.enumeratedObjects.count - state->state);
		[self.enumeratedObjects getObjects:buffer range:NSMakeRange(state->state, count)];
		state->state += count;
	}
	
	return count;
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	return self;
}

@end

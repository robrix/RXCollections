//  RXTraversalArray.m
//  Created by Rob Rix on 2013-03-03.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXTraversalArray.h"
#import "RXIntervalTraversal.h"
#import <Lagrangian/Lagrangian.h>

@l3_suite("RXTraversalArray");

@l3_set_up {
	test[@"items"] = [RXIntervalTraversal traversalWithInterval:RXIntervalMake(0, 32)];
	test[@"array"] = [RXTraversalArray arrayWithFastEnumeration:test[@"items"]];
}

const NSUInteger RXTraversalArrayUnknownCount = NSUIntegerMax;

@interface RXTraversalArray ()

@property (nonatomic, strong) id<NSFastEnumeration> enumeration;
@property (nonatomic, assign) NSUInteger internalCount;
@property (nonatomic, assign, readonly) NSFastEnumerationState state;
@property (nonatomic, strong) NSMutableArray *enumeratedObjects;

@end

@implementation RXTraversalArray

#pragma mark Construction

+(instancetype)arrayWithFastEnumeration:(id<NSFastEnumeration>)enumeration count:(NSUInteger)count {
	return [[self alloc] initWithFastEnumeration:enumeration count:count];
}

+(instancetype)arrayWithFastEnumeration:(id<NSFastEnumeration>)enumeration {
	return [self arrayWithFastEnumeration:enumeration count:RXTraversalArrayUnknownCount];
}

-(instancetype)initWithFastEnumeration:(id<NSFastEnumeration>)enumeration count:(NSUInteger)count {
	if ((self = [super init])) {
		_enumeration = enumeration;
		_internalCount = count;
	}
	return self;
}


#pragma mark NSArray primitives

@l3_test("count can be passed in to avoid traversing the entire enumeration") {
	RXTraversalArray *array = [RXTraversalArray arrayWithFastEnumeration:test[@"items"] count:[test[@"items"] count]];
	[array count];
	l3_assert(array.enumeratedObjects, nil);
}

@l3_test("if count is inferred, it must traverse the entire enumeration") {
	RXTraversalArray *array = test[@"array"];
	[array count];
	l3_assert(array.enumeratedObjects.count, 32);
}

-(NSUInteger)count {
	if (self.internalCount == RXTraversalArrayUnknownCount)
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

-(void)populateUpToIndex:(NSUInteger)index {
	if (!self.enumeration || self.enumeratedObjects.count > index)
		return;
	
	if (!self.enumeratedObjects)
		self.enumeratedObjects = [NSMutableArray new];
	
	__unsafe_unretained id objects[16];
	while (self.enumeratedObjects.count <= index) {
		NSUInteger count = [self.enumeration countByEnumeratingWithState:&_state objects:objects count:sizeof objects / sizeof *objects];
		if (count == 0) {
			self.internalCount = self.enumeratedObjects.count;
			self.enumeration = nil;
			break;
		}
		
		for (NSUInteger i = 0; i < count; i++) {
			[self.enumeratedObjects addObject:objects[i]];
		}
	}
}

@end

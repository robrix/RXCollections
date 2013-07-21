//  RXSparseArray.m
//  Created by Rob Rix on 7/21/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXAllocation.h"
#import "RXSingleton.h"
#import "RXSparseArray.h"

#import <stdlib.h>
#import <Lagrangian/Lagrangian.h>

@l3_suite("RXSparseArray");

typedef struct {
	NSUInteger index;
	__unsafe_unretained id object;
} RXSparseArraySlot;

#define RXUnionCast(value, type) ((union{__typeof__(value) from; type to; })value).to

static inline RXSparseArraySlot *RXSparseArrayGetSlot(void *buffer, NSUInteger index) {
	return RXUnionCast(buffer, RXSparseArraySlot *) + index;
}

static inline void RXSparseArraySlotSetIndexAndObject(RXSparseArraySlot *slot, NSUInteger index, id object) {
	slot->index = index;
	id __strong *strongObject = (id __strong *)(void *)&slot->object;
	*strongObject = object;
}

static inline NSComparisonResult _RXSparseArraySlotCompare(const NSUInteger *left, const NSUInteger *right) {
	NSComparisonResult result = NSOrderedSame;
	if (*left < *right)
		result = NSOrderedAscending;
	else if (*left > *right)
		result = NSOrderedDescending;
	return result;
}

static inline int RXSparseArraySlotCompare(const void *left, const void *right) {
	return _RXSparseArraySlotCompare(left, right);
}



@implementation RXSparseArray

+(instancetype)allocWithZone:(NSZone *)zone {
	return RXSingleton(self, ^id{ return [[self allocateWithExtraSize:0] init]; });
}

-(instancetype)initWithObjects:(const id [])objects atIndices:(const NSUInteger [])indices count:(NSUInteger)count {
	if ((self = [[self.class allocateWithExtraSize:sizeof(RXSparseArraySlot) * count] init])) {
		_elementCount = count;
		void *contents = self.extraSpace;
		for (NSUInteger i = 0; i < _elementCount; i++) {
			RXSparseArraySlotSetIndexAndObject(RXSparseArrayGetSlot(contents, i), indices[i], objects[i]);
		}
		
		qsort(contents, _elementCount, sizeof(RXSparseArraySlot), RXSparseArraySlotCompare);
		
		_count = RXSparseArrayGetSlot(contents, _elementCount - 1)->index + 1;
	}
	return self;
}

/*
 Since this the extra space associated with instances is not managed by ARC at compile-time, it does not have the information necessary to release it. Therefore, we assign nil to each element to allow ARC to manage lifetimes explicitly, per http://clang.llvm.org/docs/AutomaticReferenceCounting.html#conversion-of-pointers-to-ownership-qualified-types
 */
-(void)dealloc {
	void *contents = self.extraSpace;
	for (NSUInteger i = 0; i < _elementCount; i++) {
		RXSparseArraySlotSetIndexAndObject(RXSparseArrayGetSlot(contents, i), 0, nil);
	}
}


@l3_test("has an element count equal to the number of elements it contains") {
	RXSparseArray *array = [[RXSparseArray alloc] initWithObjects:(const id []){ @1, @2 } atIndices:(const NSUInteger []){ 10, 20 } count:2];
	l3_assert(array.elementCount, 2);
}


@l3_test("has a count equal to 1 + the maximum index of its elements") {
	RXSparseArray *array = [[RXSparseArray alloc] initWithObjects:(const id []){nil} atIndices:(const NSUInteger []){10190} count:1];
	l3_assert(array.count, 10191);
}


@l3_test("retrieves objects by index") {
	NSArray *array = [[RXSparseArray alloc] initWithObjects:(const id []){ @1, @2, @3, @4 } atIndices:(const NSUInteger []){ 10, 20, 30, 40 } count:4];
	l3_assert(array[30], @3);
}

-(id)objectAtIndex:(NSUInteger)index {
	RXSparseArraySlot *slot = NULL;
	id object;
	if ((slot = bsearch(&index, self.extraSpace, _elementCount, sizeof(RXSparseArraySlot), RXSparseArraySlotCompare))) {
		object = slot->object;
	}
	return object;
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	return self;
}

@end

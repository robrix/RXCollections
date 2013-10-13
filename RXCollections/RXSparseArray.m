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

/**
 Casts a value to a given type by embedding it in a union. This algebraic data type–esque approach is safe in the presence of strict aliasing.
 */
#define RXUnionCast(value, type) ((union{__typeof__(value) from; type to; })value).to

static inline RXSparseArraySlot *RXSparseArrayGetSlot(RXSparseArraySlot *slots, NSUInteger index) {
	return slots + index;
}

static inline void RXSparseArraySlotSetIndex(RXSparseArraySlot *slot, NSUInteger index) {
	slot->index = index;
}

static inline void RXSparseArraySlotSetObject(RXSparseArraySlot *slot, id object) {
	id __strong *strongObject = (id __strong *)(void *)&slot->object;
	*strongObject = object;
}

static inline void RXSparseArraySetSlot(RXSparseArraySlot *from, RXSparseArraySlot *to) {
	RXSparseArraySlotSetIndex(from, to->index);
	RXSparseArraySlotSetObject(from, to->object);
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


static inline RXSparseArraySlot *RXSparseArrayGetSlotAtIndex(RXSparseArraySlot *slots, NSUInteger elementCount, NSUInteger index) {
	return bsearch(&index, slots, elementCount, sizeof(RXSparseArraySlot), RXSparseArraySlotCompare);
}

static inline id RXSparseArrayGetObjectAtIndex(RXSparseArraySlot *slots, NSUInteger elementCount, NSUInteger index) {
	RXSparseArraySlot *slot = RXSparseArrayGetSlotAtIndex(slots, elementCount, index);
	return slot? slot->object : nil;
}

static inline NSUInteger RXSparseArrayGetCount(RXSparseArraySlot *slots, NSUInteger elementCount) {
	return (slots + elementCount - 1)->index + 1;
}

static inline NSUInteger RXSparseArraySortAndCount(RXSparseArraySlot *slots, NSUInteger elementCount) {
	qsort(slots, elementCount, sizeof(RXSparseArraySlot), RXSparseArraySlotCompare);
	return RXSparseArrayGetCount(slots, elementCount);
}


static inline NSUInteger RXSparseArrayCopyObjectsAndIndices(RXSparseArraySlot *slots, NSUInteger elementCount, const id objects[elementCount], const NSUInteger indices[elementCount]) {
	for (NSUInteger i = 0; i < elementCount; i++) {
		RXSparseArraySlotSetIndex(RXSparseArrayGetSlot(slots, i), indices[i]);
		RXSparseArraySlotSetObject(RXSparseArrayGetSlot(slots, i), objects[i]);
	}
	
	return RXSparseArraySortAndCount(slots, elementCount);
}


static inline NSUInteger RXMutableSparseArrayCapacityForCount(NSUInteger count) {
	const CGFloat bySteps = 8;
	return ceilf(((CGFloat)count) / bySteps) * 8;
}


@implementation RXSparseArray

+(instancetype)allocWithZone:(NSZone *)zone {
	return RXSingleton(self, ^id{ return [[self allocateWithExtraSize:0] init]; });
}


+(instancetype)arrayWithObjects:(const id [])objects atIndices:(const NSUInteger [])indices count:(NSUInteger)count {
	return [[self alloc] initWithObjects:objects atIndices:indices count:count];
}

-(instancetype)initWithObjects:(const id [])objects atIndices:(const NSUInteger [])indices count:(NSUInteger)count {
	if ((self = [[self.class allocateWithExtraSize:sizeof(RXSparseArraySlot) * count] init])) {
		_elementCount = count;
		_count = RXSparseArrayCopyObjectsAndIndices(self.extraSpace, _elementCount, objects, indices);
	}
	return self;
}

/*
 Since this the extra space associated with instances is not managed by ARC at compile-time, it does not have the information necessary to release it. Therefore, we assign nil to each element to allow ARC to manage lifetimes explicitly, per http://clang.llvm.org/docs/AutomaticReferenceCounting.html#conversion-of-pointers-to-ownership-qualified-types
 */
-(void)dealloc {
	void *contents = self.extraSpace;
	for (NSUInteger i = 0; i < _elementCount; i++) {
		RXSparseArraySlotSetObject(RXSparseArrayGetSlot(contents, i), nil);
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


@l3_test("returns objects by index") {
	NSArray *array = [[RXSparseArray alloc] initWithObjects:(const id []){ @1, @2, @3, @4 } atIndices:(const NSUInteger []){ 10, 20, 30, 40 } count:4];
	l3_assert(array[30], @3);
}

-(id)objectAtIndex:(NSUInteger)index {
	return RXSparseArrayGetObjectAtIndex(self.extraSpace, _elementCount, index);
}


@l3_test("enumerates sparsely") {
	RXSparseArray *array = [[RXSparseArray alloc] initWithObjects:(const id[]){ @1, @2 } atIndices:(const NSUInteger[]){ 10, 20 } count:2];
	NSMutableDictionary *enumerated = [NSMutableDictionary new];
	[array enumerateObjectsWithOptions:0 usingBlock:^(id object, NSUInteger index, BOOL *stop) {
		enumerated[@(index)] = object;
	}];
	l3_assert(enumerated, (@{ @10: @1, @20: @2 }));
}

@l3_test("can enumerate in reverse") {
	RXSparseArray *array = [[RXSparseArray alloc] initWithObjects:(const id[]){ @1, @2 } atIndices:(const NSUInteger[]){ 10, 20 } count:2];
	NSMutableArray *indices = [NSMutableArray new];
	[array enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger index, BOOL *stop) {
		[indices addObject:@(index)];
	}];
	l3_assert(indices, (@[@20, @10]));
}

-(void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id, NSUInteger, BOOL *))block {
	NSParameterAssert(block != nil);
	
	void *contents = self.extraSpace;
	__block BOOL stop = NO;
	if (opts & NSEnumerationConcurrent) {
		dispatch_queue_t queue = dispatch_queue_create("com.antitypical.RXSparseArray.enumerateObjectsWithOptions", DISPATCH_QUEUE_CONCURRENT);
		dispatch_apply(_elementCount, queue, ^(size_t i) {
			if (!stop) {
				RXSparseArraySlot *slot = RXSparseArrayGetSlot(contents, i);
				block(slot->object, slot->index, &stop);
			}
		});
	} else {
		for (NSUInteger i = 0; i < _elementCount; i++) {
			RXSparseArraySlot *slot = RXSparseArrayGetSlot(contents, opts & NSEnumerationReverse? _elementCount - 1 - i : i);
			block(slot->object, slot->index, &stop);
			if (stop) break;
		}
	}
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	return self;
}


#pragma mark NSFastEnumeration

@l3_test("implements fast enumeration over its elements") {
	NSMutableArray *indices = [NSMutableArray new];
	NSArray *array = [[RXSparseArray alloc] initWithObjects:(const id[]){@1, @2, @3, @4} atIndices:(const NSUInteger[]){1, 2, 3, 5} count:4];
	for (NSNumber *index in array) { [indices addObject:index]; }
	l3_assert(indices, (@[@1, @2, @3, @4]));
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	state->mutationsPtr = state->extra;
	state->itemsPtr = buffer;
	
	NSUInteger produced = 0;
	if (state->state < _elementCount) {
		buffer[0] = RXSparseArrayGetSlot(self.extraSpace, state->state)->object;
		produced = 1;
		state->state += produced;
	}
	return produced;
}

@end


@l3_suite("RXMutableSparseArray");

@implementation RXMutableSparseArray {
	NSUInteger _capacity;
	RXSparseArraySlot *_contents;
}

+(instancetype)arrayWithObjects:(const id [])objects atIndices:(const NSUInteger [])indices count:(NSUInteger)count {
	return [[self alloc] initWithObjects:objects atIndices:indices count:count];
}

-(instancetype)initWithObjects:(const id [])objects atIndices:(const NSUInteger [])indices count:(NSUInteger)count {
	if ((self = [super init])) {
		_contents = calloc(count, sizeof(RXSparseArraySlot));
		_capacity = count;
		_elementCount = count;
		_count = RXSparseArrayCopyObjectsAndIndices(_contents, _elementCount, objects, indices);
	}
	return self;
}

-(instancetype)init {
	if ((self = [super init])) {
		_contents = calloc(8, sizeof(RXSparseArraySlot));
		_capacity = 8;
	}
	return self;
}

-(void)dealloc {
	for (NSUInteger i = 0; i < _elementCount; i++) {
		RXSparseArraySlotSetObject(RXSparseArrayGetSlot(_contents, i), nil);
	}
	free(_contents);
}


-(void)resizeForElementCount:(NSUInteger)count {
	NSUInteger newCapacity = RXMutableSparseArrayCapacityForCount(count);
	if (_capacity < newCapacity) {
		_contents = realloc(_contents, newCapacity);
	}
}


-(id)objectAtIndex:(NSUInteger)index {
	return RXSparseArrayGetObjectAtIndex(_contents, _elementCount, index);
}


-(void)insertObject:(id)object atIndex:(NSUInteger)index {
	[self resizeForElementCount:_elementCount + 1];
}

@l3_test("removing an element reduces the indices of later elements") {
	RXMutableSparseArray *array = [RXMutableSparseArray arrayWithObjects:(const id []){ @1, @2 } atIndices:(const NSUInteger[]){ 100, 200 } count:2];
	
	[array removeObjectAtIndex:100];
	
	l3_assert(array[199], @2);
}

@l3_test("removing an element reduces the element count accordingly") {
	RXMutableSparseArray *array = [RXMutableSparseArray arrayWithObjects:(const id []){ @1, @2 } atIndices:(const NSUInteger[]){ 100, 200 } count:2];
	
	[array removeObjectAtIndex:100];
	
	l3_assert(array.elementCount, 1);
}

@l3_test("removing an element reduces the count accordingly") {
	RXMutableSparseArray *array = [RXMutableSparseArray arrayWithObjects:(const id []){ @1, @2 } atIndices:(const NSUInteger[]){ 100, 200 } count:2];
	
	[array removeObjectAtIndex:100];
	
	l3_assert(array.count, 200);
}

-(void)removeObjectAtIndex:(NSUInteger)index {
	NSParameterAssert(_elementCount > 0);
	
	[self resizeForElementCount:_elementCount - 1];
	
	RXSparseArraySlot *slot = RXSparseArrayGetSlotAtIndex(_contents, _elementCount, index);
	if (slot) {
		RXSparseArraySlot *previous = slot;
		while (slot < _contents + _elementCount) {
			RXSparseArraySlotSetIndex(slot, slot->index - 1);
			
			RXSparseArraySetSlot(previous, slot);
			
			previous = slot;
			slot++;
		}
		_elementCount--;
		_count--;
	}
}

-(void)addObject:(id)object {
	[self resizeForElementCount:_elementCount + 1];
	
	RXSparseArraySlotSetObject(RXSparseArrayGetSlot(_contents, _elementCount), object);
	_elementCount++;
}

-(void)removeLastObject {
	NSParameterAssert(_elementCount > 0);
	
	[self resizeForElementCount:_elementCount - 1];
	
	RXSparseArraySlotSetObject(RXSparseArrayGetSlot(_contents, _elementCount - 1), nil);
	_elementCount--;
}

-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object {
	RXSparseArraySlot *slot = RXSparseArrayGetSlotAtIndex(_contents, _elementCount, index);
	if (slot) {
		RXSparseArraySlotSetObject(slot, object);
	} else {
		[self insertObject:object atIndex:index];
	}
}

@end

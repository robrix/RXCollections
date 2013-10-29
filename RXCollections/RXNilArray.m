//  RXNilArray.m
//  Created by Rob Rix on 7/21/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXAllocation.h"
#import "RXNilArray.h"
#import "RXSingleton.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXNilArray");

@implementation RXNilArray

+(instancetype)allocWithZone:(NSZone *)zone {
	return RXSingleton(self, ^{ return [self allocateWithExtraSize:0]; });
}


@l3_test("can contain non-nil entries") {
	NSArray *array = [[RXNilArray alloc] initWithObjects:(const id[]){ test } count:1];
	l3_assert(array[0], test);
}

@l3_test("can contain nil entries") {
	NSArray *array = [[RXNilArray alloc] initWithObjects:(const id [1]){ nil } count:1];
	l3_assert(array[0], nil);
}

-(instancetype)initWithObjects:(const id [])objects count:(NSUInteger)count {
	NSParameterAssert(objects != NULL);
	if ((self = [[self.class allocateWithExtraSize:sizeof(*objects) * count] init])) {
		_count = count;
		id __strong *contents = (id __strong *)self.extraSpace;
		for (NSUInteger i = 0; i < count; i++) {
			contents[i] = objects[i];
		}
	}
	return self;
}

/*
 Since this the extra space associated with instances is not managed by ARC at compile-time, it does not have the information necessary to release it. Therefore, we assign nil to each element to allow ARC to manage lifetimes explicitly, per http://clang.llvm.org/docs/AutomaticReferenceCounting.html#conversion-of-pointers-to-ownership-qualified-types
 */
-(void)dealloc {
	id __strong *contents = (id __strong *)self.extraSpace;
	for (NSUInteger i = 0; i < _count; i++) {
		contents[i] = nil;
	}
}


#pragma mark NSArray

-(id)objectAtIndex:(NSUInteger)index {
	NSParameterAssert(index < _count);
	
	return ((id __strong *)self.extraSpace)[index];
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	return self;
}

@end


@l3_suite("RXMutableNilArray");

@interface RXMutableNilArray ()

@property (nonatomic) id __strong *objects;
@property (nonatomic) NSUInteger count;
@property (nonatomic) NSUInteger capacity;

@end

@implementation RXMutableNilArray

-(instancetype)initWithObjects:(const id [])objects count:(NSUInteger)count {
	if ((self = [super init])) {
		id __strong *contents = [self bufferForCount:count];
		for (NSUInteger i = 0; i < count; i++) {
			contents[i] = objects[i];
		}
		_count = count;
	}
	return self;
}

-(void)dealloc {
	for (NSUInteger i = 0; i < _count; i++) {
		_objects[i] = nil;
	}
	free(_objects);
}


@l3_test("calculates its capacity in multiples of 8") {
	l3_assert([[RXMutableNilArray new] capacityForCount:0], 0);
	l3_assert([[RXMutableNilArray new] capacityForCount:1], 8);
	l3_assert([[RXMutableNilArray new] capacityForCount:7], 8);
	l3_assert([[RXMutableNilArray new] capacityForCount:8], 8);
	l3_assert([[RXMutableNilArray new] capacityForCount:9], 16);
}

-(NSUInteger)capacityForCount:(NSUInteger)count {
	const CGFloat granularity = 8;
	return ceilf(((CGFloat)count) / granularity) * granularity;
}

-(id __strong *)bufferForCount:(NSUInteger)count {
	NSUInteger newCapacity = [self capacityForCount:count];
	if (newCapacity > self.capacity) {
		void *buffer = realloc(self.objects, newCapacity * sizeof(id));
		memset(buffer + (self.capacity * sizeof(id)), 0, (newCapacity - self.capacity) * sizeof(id));
		self.objects = (id __strong *)buffer;
		self.capacity = newCapacity;
	}
	return self.objects;
}


#pragma mark NSArray

-(id)objectAtIndex:(NSUInteger)index {
	NSParameterAssert(index < self.count);
	
	return self.objects[index];
}


#pragma mark NSMutableArray

@l3_test("insertions at the end don't move anything") {
	NSMutableArray *array = [RXMutableNilArray new];
	[array insertObject:@0 atIndex:0];
	[array insertObject:@1 atIndex:1];
	[array insertObject:@2 atIndex:2];
	l3_assert(array, (@[@0, @1, @2]));
}

@l3_test("nil insertions are accepted") {
	NSMutableArray *array = [RXMutableNilArray new];
	[array insertObject:nil atIndex:0];
	l3_assert([array objectAtIndex:0], nil);
}

@l3_test("insertions in the middle move later elements") {
	NSMutableArray *array = [RXMutableNilArray new];
	[array addObject:@0];
	[array insertObject:@1 atIndex:0];
	l3_assert(array, (@[@1, @0]));
}

@l3_test("insertions increment count") {
	NSMutableArray *array = [RXMutableNilArray new];
	l3_assert(array.count, 0);
	[array addObject:@0];
	l3_assert(array.count, 1);
	[array insertObject:@1 atIndex:0];
	l3_assert(array.count, 2);
}

-(void)insertObject:(id)object atIndex:(NSUInteger)index {
	NSParameterAssert(index <= self.count);
	id __strong *buffer = [self bufferForCount:self.count + 1];
	memmove((void *)buffer + ((index + 1) * sizeof(id)), (void *)(buffer + (index * sizeof(id))), (self.count - index) * sizeof(id));
	self.count++;
	[self replaceObjectAtIndex:index withObject:object];
}

@l3_test("removals decrement the count") {
	NSMutableArray *array = [RXMutableNilArray new];
	[array addObject:@0];
	l3_assert(array.count, 1);
	[array removeObjectAtIndex:0];
	l3_assert(array.count, 0);
}

@l3_test("removals move later elements earlier") {
	NSMutableArray *array = [RXMutableNilArray new];
	[array addObject:@0];
	[array addObject:@1];
	[array addObject:@2];
	[array removeObjectAtIndex:1];
	l3_assert(array, (@[@0, @2]));
}

-(void)removeObjectAtIndex:(NSUInteger)index {
	NSParameterAssert(index < self.count);
	id __strong *buffer = [self bufferForCount:self.count - 1];
	memmove((void *)buffer + (index * sizeof(id)), (void *)buffer + ((index + 1) * sizeof(id)), self.count - index);
	self.count--;
}

-(void)addObject:(id)object {
	[self insertObject:object atIndex:self.count];
}

-(void)removeLastObject {
	[self removeObjectAtIndex:self.count - 1];
}

-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object {
	NSParameterAssert(index < self.count);
	
	self.objects[index] = object;
}

@end

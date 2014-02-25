//  RXNilArray.m
//  Created by Rob Rix on 7/21/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXAllocation.h"
#import "RXNilArray.h"
#import "RXSingleton.h"

#import <Lagrangian/Lagrangian.h>

@implementation RXNilArray

+(instancetype)allocWithZone:(NSZone *)zone {
	return RXSingleton(self, ^{ return [self allocateWithExtraSize:0]; });
}


l3_test(@selector(initWithObjects:count:), ^{
	NSArray *array = [[RXNilArray alloc] initWithObjects:(const id[]){ self } count:1];
	l3_expect(array[0]).to.equal(self);
})

l3_test(@selector(initWithObjects:count:), ^{
	NSArray *array = [[RXNilArray alloc] initWithObjects:(const id [1]){ nil } count:1];
	l3_expect(array[0]).to.equal(nil);
})

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


l3_test(@selector(capacityForCount:), ^{
	l3_expect([[RXMutableNilArray new] capacityForCount:0]).to.equal(@0);
	l3_expect([[RXMutableNilArray new] capacityForCount:1]).to.equal(@8);
	l3_expect([[RXMutableNilArray new] capacityForCount:7]).to.equal(@8);
	l3_expect([[RXMutableNilArray new] capacityForCount:8]).to.equal(@8);
	l3_expect([[RXMutableNilArray new] capacityForCount:9]).to.equal(@16);
})

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

l3_test(@selector(insertObject:atIndex:), ^{
	RXMutableNilArray *array = [RXMutableNilArray new];
	[array insertObject:@0 atIndex:0];
	[array insertObject:@1 atIndex:1];
	[array insertObject:@2 atIndex:2];
	l3_expect(array).to.equal(@[@0, @1, @2]);
	
	[array insertObject:nil atIndex:1];
	l3_expect(array[1]).to.equal(nil);
	l3_expect(array[2]).to.equal(@1);
	l3_expect(array.count).to.equal(@4);
})

-(void)insertObject:(id)object atIndex:(NSUInteger)index {
	NSParameterAssert(index <= self.count);
	id __strong *buffer = [self bufferForCount:self.count + 1];
	memmove((void *)(buffer + index + 1), (void *)(buffer + index), (self.count - index) * sizeof(id));
	memset((void *)(buffer + index), 0, sizeof(id));
	self.count++;
	[self replaceObjectAtIndex:index withObject:object];
}

l3_test(@selector(removeObjectAtIndex:), ^{
	NSMutableArray *array = [RXMutableNilArray new];
	[array addObject:@1];
	[array addObject:@0];
	l3_expect(array.count).to.equal(@2);
	[array removeObjectAtIndex:0];
	l3_expect(array.count).to.equal(@1);
	l3_expect(array[0]).to.equal(@0);
})

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

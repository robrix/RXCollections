//  RXTraversal.m
//  Created by Rob Rix on 2013-03-13.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXTraversal.h"

#import <Lagrangian/Lagrangian.h>

const NSUInteger RXTraversalUnknownCount = NSUIntegerMax;

@interface RXTraversal : NSObject <RXTraversal>
@property (nonatomic, assign, readonly) id const *objects; // subclass responsibility
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSUInteger current;
@end

@interface RXRefillingTraversal : RXTraversal
-(void)refill; // subclass responsibility
@end

@interface RXSourcedTraversal : RXRefillingTraversal <RXRefillableTraversal>
+(instancetype)traversalWithSource:(RXTraversalSource)source;

@property (nonatomic, copy) RXTraversalSource source;
@property (nonatomic, readonly) NSUInteger capacity;
@end

@interface RXFastEnumerationTraversal : RXRefillingTraversal
+(instancetype)traversalWithEnumeration:(id<NSFastEnumeration>)enumeration;

@property (nonatomic, strong) id<NSFastEnumeration> enumeration;
@end

@interface RXInteriorTraversal : RXTraversal
+(instancetype)traversalWithInteriorObjects:(id const *)objects count:(NSUInteger)count owner:(id)owner;

@property (nonatomic, assign, readwrite) id const *objects;
@property (nonatomic, strong) id owner;
@end

@implementation RXTraversal

-(id const __unsafe_unretained *)objects {
	[self doesNotRecognizeSelector:_cmd];
	return NULL;
}


-(bool)isExhausted {
	return self.count <= self.current;
}

-(id)nextObject {
	id nextObject = nil;
	if (!self.isExhausted)
		nextObject = self.objects[self.current++];
	return nextObject;
}


#pragma mark NSFastEnumeration

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	NSUInteger count = 0;
	if (!self.isExhausted) {
		state->itemsPtr = (__unsafe_unretained id *)self.objects;
		state->mutationsPtr = state->extra;
		state->state = count = self.current = self.count;
	}
	return count;
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	RXTraversal *copy = [self.class new];
	copy.current = self.current;
	copy.count = self.count;
	return copy;
}

@end


@implementation RXRefillingTraversal

-(void)refill {
	[self doesNotRecognizeSelector:_cmd];
}

-(bool)isExhausted {
	if (super.isExhausted)
		[self refill];
	return super.isExhausted;
}

@end


@implementation RXSourcedTraversal {
	id __strong _objects[16];
}

+(instancetype)traversalWithSource:(RXTraversalSource)source {
	NSParameterAssert(source != nil);
	
	RXSourcedTraversal *traversal = [self new];
	traversal.source = source;
	return traversal;
}


-(const __unsafe_unretained id *)objects {
	return _objects;
}

-(NSUInteger)capacity {
	return sizeof(_objects) / sizeof(*_objects);
}


-(void)empty {
	self.count = 0;
	self.current = 0;
}

-(void)refill {
	[self empty];
	
	while ((self.source != nil) && (self.count < self.capacity)) {
		if (self.source(self))
			self.source = nil;
	}
}


-(void)addObject:(id)object {
	_objects[self.count++] = object;
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	RXSourcedTraversal *copy = [super copyWithZone:zone];
	copy.source = self.source;
	for (NSUInteger i = 0; i < self.count; i++) {
		copy->_objects[i] = _objects[i];
	}
	return copy;
}

@end


@l3_suite("RXFastEnumerationTraversal");

@implementation RXFastEnumerationTraversal {
	NSFastEnumerationState _state;
	id __unsafe_unretained _objects[16];
}

+(instancetype)traversalWithEnumeration:(id<NSFastEnumeration>)enumeration {
	RXFastEnumerationTraversal *source = [self new];
	source.enumeration = enumeration;
	return source;
}


-(const __unsafe_unretained id *)objects {
	return _state.itemsPtr;
}


-(void)refill {
	self.current = 0;
	self.count = [self.enumeration countByEnumeratingWithState:&_state objects:_objects count:sizeof(_objects) / sizeof(*_objects)];
}


#pragma mark NSCopying

@l3_step("copy") {
	test[@"original"] = [RXFastEnumerationTraversal traversalWithEnumeration:@[@1, @2, @3]];
	[test[@"original"] nextObject];
	test[@"copy"] = [test[@"original"] copy];
}

@l3_test("copies traverse from the current location") {
	l3_perform_step("copy");
	l3_assert([test[@"copy"] nextObject], @2);
}

@l3_test("copies are independently traversed") {
	l3_perform_step("copy");
	[test[@"copy"] nextObject];
	l3_assert([test[@"original"] nextObject], @2);
}

-(instancetype)copyWithZone:(NSZone *)zone {
	RXFastEnumerationTraversal *copy = [super copyWithZone:zone];
	copy.enumeration = self.enumeration;
	copy->_state = _state;
	memcpy(&copy->_objects, &_objects, sizeof _objects);
	return copy;
}

@end


@l3_suite("RXInteriorTraversal");

@implementation RXInteriorTraversal

@synthesize objects = _objects;


+(instancetype)traversalWithInteriorObjects:(const id *)objects count:(NSUInteger)count owner:(id)owner {
	NSParameterAssert(objects != NULL);
	NSParameterAssert(owner != nil);
	
	RXInteriorTraversal *traversal = [self new];
	traversal.objects = objects;
	traversal.count = count;
	traversal.owner = owner;
	return traversal;
}


-(bool)isExhausted {
	bool isExhausted = super.isExhausted;
	if (isExhausted)
		self.owner = nil;
	return isExhausted;
}


#pragma mark NSCopying

@l3_step("copy") {
	test[@"original"] = [RXFastEnumerationTraversal traversalWithEnumeration:@[@1, @2, @3]];
	[test[@"original"] nextObject];
	test[@"copy"] = [test[@"original"] copy];
}

@l3_test("copies traverse from the current location") {
	l3_perform_step("copy");
	l3_assert([test[@"copy"] nextObject], @2);
}

@l3_test("copies are independently traversed") {
	l3_perform_step("copy");
	[test[@"copy"] nextObject];
	l3_assert([test[@"original"] nextObject], @2);
}

-(instancetype)copyWithZone:(NSZone *)zone {
	RXInteriorTraversal *copy = [super copyWithZone:zone];
	copy.objects = self.objects;
	copy.owner = self.owner;
	return copy;
}

@end


id<RXTraversal> RXTraversalWithObjects(id owner, const id *objects, NSUInteger count) {
	return [RXInteriorTraversal traversalWithInteriorObjects:objects count:count owner:owner];
}

id<RXTraversal> RXTraversalWithSource(RXTraversalSource source) {
	return [RXSourcedTraversal traversalWithSource:source];
}

id<RXTraversal> RXTraversalWithEnumeration(id<NSObject, NSFastEnumeration> enumeration) {
	return [enumeration isKindOfClass:[RXTraversal class]]?
		(RXTraversal *)enumeration
	:	[RXFastEnumerationTraversal traversalWithEnumeration:enumeration];
}

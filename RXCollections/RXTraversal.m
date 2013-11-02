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

@property (nonatomic, readonly) id currentObject;
-(id)objectByAdvancingCursor;

@end

@interface RXRefillingTraversal : RXTraversal
-(void)refill; // subclass responsibility
@end

@interface RXSourcedTraversal : RXRefillingTraversal <RXRefillableTraversal>
+(instancetype)traversalWithSource:(RXTraversalSource)source;

@property (nonatomic, copy) RXTraversalSource source;
@property (nonatomic, readonly) NSUInteger capacity;
@end

@interface RXCompositeTraversal : RXSourcedTraversal <RXCompositeTraversal>
+(instancetype)traversalWithSource:(RXCompositeTraversalSource)source;

@property (nonatomic, readonly) id<RXTraversal> currentObject;
@property (nonatomic, copy) RXCompositeTraversalSource source;
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

@interface RXUnaryTraversal : NSObject <RXTraversal>
+(instancetype)traversalWithObject:(id)object;

@property (nonatomic, strong) id object;
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
		nextObject = [self objectByAdvancingCursor];
	return nextObject;
}


-(id)currentObject {
	return self.objects[self.current];
}

-(id)objectByAdvancingCursor {
	return self.objects[self.current++];
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


@implementation RXCompositeTraversal

@dynamic source;
@dynamic currentObject;

+(instancetype)traversalWithSource:(RXCompositeTraversalSource)source {
	return [super traversalWithSource:source];
}


#pragma mark RXTraversal

-(id)objectByAdvancingCursor {
	id<RXTraversal> currentObject = self.currentObject;
	while (currentObject.isExhausted) {
		currentObject = [super objectByAdvancingCursor];
	}
	return [currentObject nextObject];
}


#pragma mark RXCompositeTraversal

-(void)addObject:(id)object {
	[super addObject:RXTraversalWithObject(object)];
}

-(void)addTraversal:(id<RXTraversal>)traversal {
	[super addObject:traversal];
}

@end


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

l3_test(@selector(copyWithZone:), ^{
	id<RXTraversal> original = [RXFastEnumerationTraversal traversalWithEnumeration:@[@1, @2, @3]];
	[original nextObject];
	id<RXTraversal> copy = [original copyWithZone:NULL];
	
	l3_expect([copy nextObject]).to.equal(@2);
	l3_expect([original nextObject]).to.equal(@2);
})

-(instancetype)copyWithZone:(NSZone *)zone {
	RXFastEnumerationTraversal *copy = [super copyWithZone:zone];
	copy.enumeration = self.enumeration;
	copy->_state = _state;
	memcpy(&copy->_objects, &_objects, sizeof _objects);
	return copy;
}

@end


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

l3_test(@selector(copyWithZone:), ^{
	id<RXTraversal> original = [RXInteriorTraversal traversalWithInteriorObjects:(const __autoreleasing id []){ @1, @2, @3 } count:3 owner:[NSObject new]];
	[original nextObject];
	id<RXTraversal> copy = [original copyWithZone:NULL];
	
	l3_expect([copy nextObject]).to.equal(@2);
	l3_expect([original nextObject]).to.equal(@2);
})

-(instancetype)copyWithZone:(NSZone *)zone {
	RXInteriorTraversal *copy = [super copyWithZone:zone];
	copy.objects = self.objects;
	copy.owner = self.owner;
	return copy;
}

@end


@implementation RXUnaryTraversal

static id RXUnaryTraversalExhaustionMarker() {
	static NSObject *marker = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		marker = [NSObject new];
	});
	return marker;
}

+(instancetype)traversalWithObject:(id)object {
	RXUnaryTraversal *traversal = [self new];
	traversal.object = object;
	return traversal;
}


-(id)nextObject {
	id object = self.object;
	self.object = RXUnaryTraversalExhaustionMarker();
	return object;
}

-(bool)isExhausted {
	return self.object == RXUnaryTraversalExhaustionMarker();
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	return [self.class traversalWithObject:self.object];
}


#pragma mark NSFastEnumeration

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	state->mutationsPtr = state->extra;
	const id *object = &_object;
	state->itemsPtr = (__unsafe_unretained id *)object;
	return self.isExhausted? 0 : 1;
}

@end


id<RXTraversal> RXTraversalWithObjects(id owner, const id *objects, NSUInteger count) {
	return [RXInteriorTraversal traversalWithInteriorObjects:objects count:count owner:owner];
}

id<RXTraversal> RXTraversalWithSource(RXTraversalSource source) {
	return [RXSourcedTraversal traversalWithSource:source];
}

id<RXTraversal> RXCompositeTraversalWithSource(RXCompositeTraversalSource source) {
	return [RXCompositeTraversal traversalWithSource:source];
}

id<RXTraversal> RXTraversalWithEnumeration(id<NSObject, NSFastEnumeration> enumeration) {
	return [enumeration isKindOfClass:[RXTraversal class]]?
		(RXTraversal *)enumeration
	:	[RXFastEnumerationTraversal traversalWithEnumeration:enumeration];
}

id<RXTraversal> RXTraversalWithObject(id object) {
	return [RXUnaryTraversal traversalWithObject:object];
}

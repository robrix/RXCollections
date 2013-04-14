//  RXTraversal.m
//  Created by Rob Rix on 2013-03-13.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXTraversal.h"

const NSUInteger RXTraversalUnknownCount = NSUIntegerMax;

@interface RXRefillingTraversal : RXTraversal
-(void)refill; // subclass responsibility
@end

@interface RXSourcedTraversal : RXRefillingTraversal <RXRefillableTraversal>
+(instancetype)traversalWithSource:(id<RXTraversalSource>)source;

@property (nonatomic, strong) id<RXTraversalSource> source;
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


@interface RXTraversal ()
@property (nonatomic, assign, readonly) id const *objects; // subclass responsibility
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSUInteger current;
@property (nonatomic, readonly) bool canConsume;
@end

@implementation RXTraversal

+(instancetype)traversalWithInteriorObjects:(const id *)objects count:(NSUInteger)count owner:(id)owner {
	return [RXInteriorTraversal traversalWithInteriorObjects:objects count:count owner:owner];
}

+(instancetype)traversalWithSource:(id<RXTraversalSource>)source {
	return [RXSourcedTraversal traversalWithSource:source];
}

+(instancetype)traversalWithEnumeration:(id<NSFastEnumeration>)enumeration {
	return [(id)enumeration isKindOfClass:[RXTraversal class]]?
		(RXTraversal *)enumeration
	:	[RXFastEnumerationTraversal traversalWithEnumeration:enumeration];
}

-(id const __unsafe_unretained *)objects {
	[self doesNotRecognizeSelector:_cmd];
	return NULL;
}


-(bool)isExhausted {
	return !self.canConsume;
}

-(bool)canConsume {
	return self.count > self.current;
}


-(id)consume {
	id consumed = nil;
	if (self.canConsume)
		consumed = self.objects[self.current++];
	return consumed;
}


#pragma mark NSFastEnumeration

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	NSUInteger count = 0;
	if (self.canConsume) {
		state->itemsPtr = (__unsafe_unretained id *)self.objects;
		state->mutationsPtr = state->extra;
		state->state = count = self.current = self.count;
	}
	return count;
}

@end


@implementation RXRefillingTraversal

-(void)refill {
	[self doesNotRecognizeSelector:_cmd];
}

-(bool)canConsume {
	if (!super.canConsume)
		[self refill];
	return super.canConsume;
}

@end


@implementation RXSourcedTraversal {
	id __strong _objects[16];
}

+(instancetype)traversalWithSource:(id<RXTraversalSource>)source {
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


-(void)refill {
	[self.source refillTraversal:self];
}


-(void)empty {
	self.count = 0;
	self.current = 0;
}

-(void)refillWithBlock:(bool(^)())block {
	[self empty];
	
	while ((self.source != nil) && (self.count < self.capacity)) {
		if (block())
			self.source = nil;
	}
}

-(void)produce:(id)object {
	_objects[self.count++] = object;
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


-(bool)canConsume {
	bool canConsume = super.canConsume;
	if (!canConsume)
		self.owner = nil;
	return canConsume;
}

@end

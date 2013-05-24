//  RXQueue.m
//  Created by Rob Rix on 2013-05-03.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXQueue.h"
#import "RXPair.h"
#import "RXEquating.h"
#import <Lagrangian/Lagrangian.h>

//@class RXQueueNode;
//typedef RXQueueNode *(^RXLazyQueueNode)();

@interface RXQueueNode : NSObject <RXLinkedListNode>

+(instancetype)nodeWithFirst:(id)first;
+(instancetype)nodeWithFirst:(id)first rest:(RXQueueNode *)rest;

@property (nonatomic) id first;
@property (nonatomic) RXQueueNode *rest;

@end


@l3_suite("RXQueue");

@l3_set_up {
	test[@"queue"] = [RXQueue new];
}

@interface RXQueue ()
@property (nonatomic) RXQueueNode *headNode;
@property (nonatomic) RXQueueNode *tailNode;
@end

@implementation RXQueue

-(id)consume {
	return [self dequeueObject];
}

@l3_test("cannot be exhausted") {
	l3_assert([RXQueue new].isExhausted, NO);
}

-(bool)isExhausted {
	return NO;
}

@l3_step("enqueue an object") {
	RXQueue *queue = test[@"queue"];
	NSString *object = test[@"object"] = @"Sesquipedalian";
	[queue enqueueObject:object];
}

@l3_test("enqueueing an object on an empty queue sets it as the head and tail") {
	l3_perform_step("enqueue an object");
	RXQueue *queue = test[@"queue"];
	l3_assert(queue.head, test[@"object"]);
}

@l3_test("enqueueing an object on a queue appends it to the tail node") {
	l3_perform_step("enqueue an object");
	RXQueue *queue = test[@"queue"];
	NSString *object = @"Parsimony";
	[queue enqueueObject:object];
	l3_assert(queue.tailNode.first, object);
}

-(void)enqueueObject:(id)object {
	self.tailNode = [RXQueueNode nodeWithFirst:object rest:self.tailNode];
	if (!self.headNode)
		self.headNode = self.tailNode;
}

-(void)enqueueTraversal:(id<RXTraversal>)traversal {
	
}


@l3_test("dequeueing from an empty queue blocks until something is added") {
	// fixme: figure out how best to test this
}

@l3_test("dequeuing returns the head object") {
	l3_perform_step("enqueue an object");
	l3_assert([test[@"queue"] dequeueObject], test[@"object"]);
}

@l3_test("dequeueing removes the head object") {
	l3_perform_step("enqueue an object");
	RXQueue *queue = test[@"queue"];
	[queue dequeueObject];
	l3_assert(queue.headNode, nil);
	l3_assert(queue.tailNode, nil);
}

-(id)dequeueObject {
	id object = self.headNode.first;
	self.headNode = self.headNode.rest;
	if (!self.headNode)
		self.tailNode = nil;
	return object;
}


@l3_test("the head of an empty queue is nil") {
	l3_assert([RXQueue new].head, nil);
}

-(id)head {
	return self.headNode.first;
}


#pragma mark NSObject

-(bool)isEqualToQueue:(RXQueue *)queue {
	return
		[queue isKindOfClass:[RXQueue class]]
	&&	NO;
}

-(BOOL)isEqual:(id)object {
	return [self isEqualToQueue:object];
}

// fixme: -description and -debugDescription


#pragma mark NSCopying

-(id)copyWithZone:(NSZone *)zone {
	return self;
}


#pragma mark NSFastEnumeration

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	return 0;
}

@end

@implementation RXQueueNode

+(instancetype)nodeWithFirst:(id)first {
	return [self nodeWithFirst:first rest:nil];
}

+(instancetype)nodeWithFirst:(id)first rest:(RXQueueNode *)rest {
	return [[self alloc] initWithObject:first rest:rest];
}

-(instancetype)initWithObject:(id)first rest:(RXQueueNode *)rest {
	if ((self = [super init])) {
		_first = first;
		_rest = rest;
	}
	return self;
}


#pragma mark NSObject

-(bool)isEqualToQueueNode:(RXQueueNode *)node {
	return
		[node isKindOfClass:[RXQueueNode class]]
	&&	RXEqual(self.first, node.first)
	&&	RXEqual(self.rest, node.rest);
}

-(BOOL)isEqual:(id)object {
	return [self isEqualToQueueNode:object];
}

@end

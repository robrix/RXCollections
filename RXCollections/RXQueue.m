//  RXQueue.m
//  Created by Rob Rix on 2013-05-03.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXQueue.h"
#import "RXPair.h"
#import "RXEquating.h"
#import <Lagrangian/Lagrangian.h>

@l3_suite("RXStream");

@class RXStreamNode;
typedef RXStreamNode *(^RXLazyStreamNode)();

#define RXDelay(x) ^{return (x);}
#define RXForce(x) (x)()

@interface RXStreamNode : NSObject

+(instancetype)nodeWithValue:(id)value next:(RXLazyStreamNode)next;

@property (nonatomic, strong, readonly) id value;
@property (nonatomic, strong, readonly) RXStreamNode *nextNode;

-(instancetype)append:(RXStreamNode *)node;

@end

@interface RXStreamNode ()
@property (nonatomic, strong, readwrite) RXStreamNode *nextNode;
@property (nonatomic, copy) RXLazyStreamNode lazyNext;
@end

@implementation RXStreamNode

+(instancetype)nodeWithValue:(id)value next:(RXLazyStreamNode)next {
	return [[self alloc] initWithValue:value next:next];
}

-(instancetype)initWithValue:(id)value next:(RXLazyStreamNode)next {
	if ((self = [super init])) {
		_value = value;
		_lazyNext = [next copy];
	}
	return self;
}


-(RXStreamNode *)forceNextNode {
	RXStreamNode *nextNode = self.lazyNext();
	self.lazyNext = nil;
	return nextNode;
}

-(RXStreamNode *)nextNode {
	return _nextNode ?: (self.nextNode = [self forceNextNode]);
}


// fixme: this does not need to delay the appended thing
-(instancetype)append:(RXStreamNode *)node {
	return [RXStreamNode nodeWithValue:self.value next:RXDelay([self.nextNode append:node])];
}


/*
-(BOOL)isEqual:(id)other
-(id)description
 */

@end


@l3_suite("RXQueue");

@l3_set_up {
	test[@"queue"] = [RXQueue new];
}

@interface RXQueue ()

@property (nonatomic, strong, readonly) RXStreamNode *forward;
@property (nonatomic, readonly) NSUInteger forwardLength;
@property (nonatomic, strong, readonly) RXStreamNode *reverse;
@property (nonatomic, readonly) NSUInteger reverseLength;

@end

@implementation RXQueue

+(instancetype)empty {
	static RXQueue *empty = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		empty = [[RXQueue alloc] initWithForward:nil length:0 reverse:nil length:0];
	});
	return empty;
}

+(instancetype)queueWithForward:(RXStreamNode *)forward length:(NSUInteger)forwardLength reverse:(RXStreamNode *)reverse length:(NSUInteger)reverseLength {
	return [[self alloc] initWithForward:forward length:forwardLength reverse:reverse length:reverseLength];
}

-(instancetype)initWithForward:(RXStreamNode *)forward length:(NSUInteger)forwardLength reverse:(RXStreamNode *)reverse length:(NSUInteger)reverseLength {
	if ((self = [super init])) {
		if (reverseLength > forwardLength) {
			_forward = [forward append:reverse];
			_forwardLength = forwardLength + reverseLength;
		} else {
			_forward = forward;
			_forwardLength = forwardLength;
			_reverse = reverse;
			_reverseLength = reverseLength;
		}
	}
	return self;
}

-(instancetype)init {
	return [self.class empty];
}


// should this block…?
-(id)consume {
	return nil;
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
	test[@"queue"] = [queue enqueueObject:object];
}

@l3_test("enqueueing an object on the empty queue returns a queue with that as its head") {
	l3_perform_step("enqueue an object");
	RXQueue *queue = test[@"queue"];
	l3_assert(queue.head, test[@"object"]);
}

@l3_test("enqueueing an object on a queue appends it to the reverse stream") {
	l3_perform_step("enqueue an object");
	RXQueue *queue = test[@"queue"];
	NSString *object = @"Parsimony";
	queue = [queue enqueueObject:object];
	l3_assert(queue.reverse.value, object);
}

-(instancetype)enqueueObject:(id)object {
	return self.forward?
		[self.class queueWithForward:self.forward length:self.forwardLength reverse:[RXStreamNode nodeWithValue:object next:RXDelay(self.reverse)] length:self.reverseLength + 1]
	:	[self.class queueWithForward:[RXStreamNode nodeWithValue:object next:nil] length:1 reverse:nil length:0];
}

-(instancetype)enqueueTraversal:(id<RXTraversal>)traversal {
	return nil;
}


@l3_test("dequeueing the empty queue returns the empty queue") {
	RXQueue *empty = [RXQueue empty];
	l3_assert([empty dequeue], empty);
}

-(instancetype)dequeue {
	return [self.class queueWithForward:self.forward.nextNode length:self.forwardLength - 1 reverse:self.reverse length:self.reverseLength];
}


@l3_test("the head of the empty queue is nil") {
	l3_assert([RXQueue empty].head, nil);
}

-(id)head {
	return self.forward.value;
}


#pragma mark NSObject

-(bool)isEqualToQueue:(RXQueue *)queue {
	return
		[queue isKindOfClass:[RXQueue class]]
	&&	(queue.forwardLength == self.forwardLength)
	&&	(queue.reverseLength == self.reverseLength)
	&&	RXEqual(queue.forward, self.forward)
	&&	RXEqual(queue.reverse, self.reverse);
}

-(BOOL)isEqual:(id)object {
	return [self isEqualToQueue:object];
}


#pragma mark NSCopying

-(id)copyWithZone:(NSZone *)zone {
	return self;
}


#pragma mark NSFastEnumeration

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	return 0;
}

@end

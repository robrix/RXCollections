//  RXQueue.h
//  Created by Rob Rix on 2013-05-03.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

/*
 is a queue a traversal? or is it traversable?
 are all traversals queues? is queue a better noun than traversal?
 should it be thread-safe?
 should it be purely functional?
 */

@interface RXQueue : NSObject <RXTraversal>

+(instancetype)empty;

-(instancetype)enqueueObject:(id)object;
-(instancetype)enqueueTraversal:(id<RXTraversal>)traversal;

-(instancetype)dequeue;

@property (nonatomic, readonly) id head;

@end

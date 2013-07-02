//  RXQueue.h
//  Created by Rob Rix on 2013-05-03.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

@interface RXQueue : NSObject <RXTraversal>

-(void)enqueueObject:(id)object;
-(void)enqueueTraversal:(id<RXTraversal>)traversal;

-(id)dequeueObject;

@property (nonatomic, readonly) id head;

@end

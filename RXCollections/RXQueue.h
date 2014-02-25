//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

@interface RXQueue : NSObject <RXTraversal>

-(void)enqueueObject:(id)object;
-(void)enqueueTraversal:(id<RXTraversal>)traversal;

-(id)dequeueObject;

@property (nonatomic, readonly) id head;

@end

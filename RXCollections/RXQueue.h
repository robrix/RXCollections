//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXEnumerator.h>

@interface RXQueue : RXEnumerator <RXEnumerator>

-(void)enqueueObject:(id)object;
-(void)enqueueEnumerator:(id<RXEnumerator>)enumerator;

-(id)dequeueObject;

@property (nonatomic, readonly) id head;

@end

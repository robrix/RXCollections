//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXEnumerator.h>

@interface RXObjectBuffer : NSEnumerator <RXOutputEnumerator, RXFiniteEnumerator>

-(instancetype)initWithCapacity:(NSUInteger)capacity;

@property (nonatomic, readonly) NSUInteger capacity;
@property (nonatomic, readonly, getter = isFull) bool full;

-(void)enqueueObject:(id)object;
-(id)dequeueObject;

@end

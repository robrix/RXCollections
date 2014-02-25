//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

@interface RXTuple : NSObject <NSCopying, RXTraversable, NSFastEnumeration>

+(instancetype)tupleWithObjects:(id const [])objects count:(NSUInteger)count;
+(instancetype)tupleWithArray:(NSArray *)array;

-(id)objectAtIndexedSubscript:(NSUInteger)subscript;

-(NSArray *)allObjects;

@property (nonatomic, readonly) NSUInteger count;

-(bool)isEqualToTuple:(RXTuple *)tuple;

@end

@interface RXTuple ()

+(instancetype)new __attribute__((unavailable));
+(instancetype)allocWithZone:(NSZone *)zone __attribute__((unavailable));
+(instancetype)alloc __attribute__((unavailable));
-(instancetype)init __attribute__((unavailable));

@end

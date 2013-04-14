//  RXTraversal.h
//  Created by Rob Rix on 2013-02-16.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

/**
 RXTraversal
 
 Defines the interface for traversing some collection of objects in sequence.
 
 At present this is basically just NSFastEnumeration, but it also conforms to NSObject, which NSFastEnumeration does not; you are expected to be able to rely on traversals being and behaving like real objects.
 */

@protocol RXTraversal <NSObject, NSFastEnumeration>
@end


@protocol RXTraversable <NSObject>

// for implementors with more than one viable traversal, this should return the default one, i.e. the one that would be used for fast enumeration
@property (nonatomic, readonly) id<RXTraversal> traversal;

@end


@protocol RXRefillableTraversal <RXTraversal>

-(void)refillWithBlock:(bool(^)())block;

-(void)empty;
-(void)produce:(id)object;

@end

@protocol RXTraversalSource <NSObject>

-(void)refillTraversal:(id<RXRefillableTraversal>)traversal;

@end

@interface RXTraversal : NSObject <RXTraversal>

+(instancetype)traversalWithInteriorObjects:(const id *)objects count:(NSUInteger)count owner:(id)owner;
+(instancetype)traversalWithSource:(id<RXTraversalSource>)source;
+(instancetype)traversalWithEnumeration:(id<NSFastEnumeration>)enumeration;

-(id)consume;

@property (nonatomic, getter = isExhausted, readonly) bool exhausted;

@end


@interface NSEnumerator (RXTraversal) <RXTraversal>
@end


/**
 RXFiniteTraversal
 
 Defines the interface for traversing some finite collection of objects with known cardinality in sequence.
 */

@protocol RXFiniteTraversal <RXTraversal>

@property (nonatomic, readonly) NSUInteger count;

@end

extern const NSUInteger RXTraversalUnknownCount;


@interface NSArray (RXFiniteTraversal) <RXFiniteTraversal>
@end

@interface NSSet (RXFiniteTraversal) <RXFiniteTraversal>
@end

@interface NSDictionary (RXFiniteTraversal) <RXFiniteTraversal>
@end

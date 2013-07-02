//  RXTraversal.h
//  Created by Rob Rix on 2013-02-16.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

/**
 @protocol RXTraversal
 
 Defines the interface for traversing some collection of objects in sequence.
*/

@protocol RXTraversal <NSObject, NSCopying, NSFastEnumeration>

-(id)nextObject;

@property (nonatomic, getter = isExhausted, readonly) bool exhausted;

@end


@protocol RXTraversable <NSObject>

// for implementors with more than one viable traversal, this should return the default one, i.e. the one that would be used for fast enumeration
@property (nonatomic, readonly) id<RXTraversal> traversal;

@end


@protocol RXRefillableTraversal;
@protocol RXCompositeTraversal;

/**
 typedef bool(^RXTraversalSource)(id<RXRefillableTraversal> traversal)
 
 An RXTraversalSource is a block which a refillable traversal will call, passing itself as the argument, when it needs to be refilled. The block can maintain any state it requires simply by closing over it.
 
 Its return value is a boolean indicating whether or not it has been exhausted; YES indicates it will not produce further objects, and NO indicates that it will. After it has returned YES, the block will not be called again.
 */
typedef bool(^RXTraversalSource)(id<RXRefillableTraversal> traversal);

typedef bool(^RXCompositeTraversalSource)(id<RXCompositeTraversal> traversal);


/**
 @protocol RXRefillableTraversal
 
 A traversal created with a source is refilled by calling its source block, which in turn receives an RXRefillableTraversal-conformant object as its argument. This protocol is not expected to be implemented by third parties.
 */
@protocol RXRefillableTraversal <RXTraversal>

@property (nonatomic, copy) RXTraversalSource source;

-(void)addObject:(id)object;

@end

@protocol RXCompositeTraversal <RXRefillableTraversal>

@property (nonatomic, copy) RXCompositeTraversalSource source;

-(void)addTraversal:(id<RXTraversal>)traversal;

@end


extern id<RXTraversal> RXTraversalWithObjects(id owner, const id *objects, NSUInteger count);
extern id<RXTraversal> RXTraversalWithSource(RXTraversalSource source);
extern id<RXTraversal> RXCompositeTraversalWithSource(RXCompositeTraversalSource source);
extern id<RXTraversal> RXTraversalWithEnumeration(id<NSObject, NSFastEnumeration> enumeration);
extern id<RXTraversal> RXTraversalWithObject(id object);


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

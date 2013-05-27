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


/**
 @protocol RXRefillableTraversal
 
 Refillable traversals can be refilled by an RXTraversalSource-conformant object. That object receives a reference to the refillable traversal, and can use the traversal’s methods to add objects to it.
 */
@protocol RXRefillableTraversal <RXTraversal>

-(void)refillWithBlock:(bool(^)())block;

-(void)empty;
-(void)addObject:(id)object;

@property (nonatomic, assign, readonly) NSUInteger countProduced;

@end


typedef bool(^RXTraversalSource)(id<RXRefillableTraversal> traversal);


extern id<RXTraversal> RXTraversalWithObjects(id owner, const id *objects, NSUInteger count);
extern id<RXTraversal> RXTraversalWithSource(RXTraversalSource source);
extern id<RXTraversal> RXTraversalWithEnumeration(id<NSObject, NSFastEnumeration> enumeration);


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

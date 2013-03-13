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


/**
 RXTraversalElement
 
 A convenience typedef for implementations of RXTraversal which traverse temporary objects.
 */
typedef __autoreleasing id RXTraversalElement;

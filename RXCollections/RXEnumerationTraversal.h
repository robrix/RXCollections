//  RXEnumerationTraversal.h
//  Created by Rob Rix on 2013-02-11.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

/**
 RXEnumerationTraversal
 
 Given an NSFastEnumeration-compliant collection or other enumeration, RXEnumerationTraversal provides a traversal (and therefore for(in) support) which traverses objects using its supplied strategy.
 
 It is expected to be used via its opaque interface, RXLazyMap, but can be used directly if the need arises.
 
 The strategy which maps individual objects can safely return nil.
 
 It is safe to enumerate these traversals reentrantly and from multiple threads, so long as each passes a different NSFastEnumeratonState to the traversal.
 
 It is not safe to drain the autorelease pool that -countByEnumeratingWithState:objects:count: is called within between successive calls to it using the same NSFastEnumerationState, as RXMappingTraversal autoreleases objects to ensure correct memory management. Draining an external autorelease pool during the body of a loop is considered bad practice under MRR, and is specifically disallowed under ARC. Plain for(in) will work under MRR or ARC. Creating and draining an autorelease pool in the body of a for(in) loop, as with the `@autoreleasepool` syntax, is safe.
 */

@protocol RXEnumerationTraversalStrategy;

@interface RXEnumerationTraversal : NSObject <RXTraversal>

+(instancetype)traversalWithEnumeration:(id<NSFastEnumeration>)enumeration block:(id(^)(id))block;

@property (nonatomic, strong, readonly) id<NSFastEnumeration> enumeration;
@property (nonatomic, copy, readonly) id(^block)(id);

@end


/**
 RXTraversalStrategy defines the means by which an enumeration traversal produces objects relating to its enumeration's objects.
 
 The enumeration's objects are provided in the `internalObjects` buffer, and their count is provided as `internalObjectsCount`.
 
 Similarly to NSFastEnumeration, it returns the count of the objects it produces; however, it always adds them to the `externalObjects` buffer, adding at most `externalObjectsCount` objects.
 
 A straightforward identity strategy, simply copying the enumeration's objects to the output buffer, would assign `MIN(interalObjectsCount, externalObjectsCount)` objects from `internalObjects` into `externalObjects` and return that number.
 
 It is safe to return nil entries in the `externalObjects` buffer.
 */

@protocol RXEnumerationTraversalStrategy <NSObject>

-(NSUInteger)countByEnumeratingObjects:(in __unsafe_unretained id [])internalObjects count:(NSUInteger)internalObjectsCount intoObjects:(out __autoreleasing id [])externalObjects count:(NSUInteger)externalObjectsCount;

@end

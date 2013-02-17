//  RXMappingTraversal.h
//  Created by Rob Rix on 2013-02-11.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

/**
 RXMappingTraversal
 
 Given an NSFastEnumeration-compliant collection or other enumeration, RXMappingTraversal provides a traversal (and therefore for(in) support) which maps the traversed objects using the supplied block.
 
 It is expected to be used via its opaque interface, RXLazyMap, but can be used directly if the need arises.
 
 The block which maps individual objects can safely return nil.
 
 It is safe to enumerate these traversals reentrantly and from multiple threads, so long as each passes a different NSFastEnumeratonState to the traversal.
 
 It is not safe to drain the autorelease pool that -countByEnumeratingWithState:objects:count: is called within between successive calls to it using the same NSFastEnumerationState, as RXMappingTraversal autoreleases objects to ensure correct memory management. Draining an external autorelease pool during the body of a loop is considered bad practice under MRR, and is specifically disallowed under ARC. Plain for(in) will work under MRR or ARC. Creating and draining an autorelease pool in the body of a for(in) loop, as with the `@autoreleasepool` syntax, is safe.
 */

@interface RXMappingTraversal : NSObject <RXTraversal>

+(instancetype)traversalWithEnumeration:(id<NSFastEnumeration>)enumeration block:(id(^)(id))block;

@property (nonatomic, strong, readonly) id<NSFastEnumeration> enumeration;
@property (nonatomic, copy, readonly) id(^block)(id);

@end

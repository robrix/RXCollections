//  RXMap.h
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>
#import <RXCollections/RXCollection.h>

typedef id (^RXMapBlock)(id each);

extern RXMapBlock const RXIdentityMapBlock;

/**
 id<RXCollection> RXMap(id<RXCollection> collection, id<RXCollection> destination, RXMapBlock block)
 
 Maps `collection` into `destination` (or, if that’s nil, into a new collection of the same type as `collection`) using `block`. `block` can return nil; nil values will generally be silently dropped.
 */

extern id<RXCollection> RXMap(id<RXCollection> collection, id<RXCollection> destination, RXMapBlock block);

/**
 id<RXTraversal> RXLazyMap(id<RXTraversal> collection, RXMapBlock block)
 
 Returns a traversal which lazily maps the values in `collection` using `block`. `block` can return nil. Further details of the contract of the returned traversal are specified in the documentation for RXMappingTraversal.
 */

extern id<RXTraversal> RXLazyMap(id<NSFastEnumeration> collection, RXMapBlock block);

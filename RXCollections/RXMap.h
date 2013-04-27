//  RXMap.h
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

typedef id (^RXMapBlock)(id each);

/**
 RXMapBlock const RXIdentityMapBlock
 
 Returns its argument.
 */

extern RXMapBlock const RXIdentityMapBlock;

/**
 id<RXTraversal> RXMap(id<NSObject, NSFastEnumeration> enumeration, RXMapBlock block)
 
 Returns a traversal which lazily maps the values in `collection` using `block`. `block` can return nil. Further details of the contract of the returned traversal are specified in the documentation for RXMappingTraversal.
 */

extern id<RXTraversal> RXMap(id<NSObject, NSFastEnumeration> enumeration, RXMapBlock block);

#pragma mark Function Pointer Support

typedef id (*RXMapFunction)(id each);

/**
 RXMapFunction const RXIdentityMapFunction
 
 Returns its argument.
 */

extern RXMapFunction const RXIdentityMapFunction;

extern id<RXTraversal> RXMapF(id<NSObject, NSFastEnumeration> enumeration, RXMapFunction function);

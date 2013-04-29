//  RXMap.h
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

typedef id (^RXMapBlock)(id each, bool *stop);
typedef id (*RXMapFunction)(id each, bool *stop);

/**
 RXMapBlock const RXIdentityMapBlock
 id RXIdentityMapFunction(id x)
 
 Returns its argument.
 */

extern RXMapBlock const RXIdentityMapBlock;
extern id RXIdentityMapFunction(id x, bool *stop);

/**
 id<RXTraversal> RXMap(id<NSObject, NSFastEnumeration> enumeration, RXMapBlock block)
 id<RXTraversal> RXMapF(id<NSObject, NSFastEnumeration> enumeration, RXMapFunction function)
 
 Returns a traversal which lazily maps the values in `collection` using `block` or `function`. `block` or `function` can return nil.
 */

extern id<RXTraversal> RXMap(id<NSObject, NSFastEnumeration> enumeration, RXMapBlock block);
extern id<RXTraversal> RXMapF(id<NSObject, NSFastEnumeration> enumeration, RXMapFunction function);

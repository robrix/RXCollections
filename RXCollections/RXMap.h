//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

typedef id (^RXMapBlock)(id each, bool *stop);
typedef id (*RXMapFunction)(id each, bool *stop);

/**
 Returns its argument.
 */

extern RXMapBlock const RXIdentityMapBlock;

/**
 Returns a traversal which lazily maps the values in `collection` using `block` or `function`. `block` or `function` can return nil.
 */

extern id<RXTraversal> RXMap(id<NSObject, NSCopying, NSFastEnumeration> enumeration, RXMapBlock block);
extern id<RXTraversal> RXMapF(id<NSObject, NSCopying, NSFastEnumeration> enumeration, RXMapFunction function);

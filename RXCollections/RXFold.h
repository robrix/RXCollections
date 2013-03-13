//  RXFold.h
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

typedef id (^RXFoldBlock)(id memo, id each); // memo is the initial value on the first invocation, and thereafter the value returned by the previous invocation of the block

/**
 id RXFold(id<RXTraversal> collection, id initial, RXFoldBlock block)
 
 Folds a `collection` with `block`, using `initial` as the `memo` argument to block for the first element.
 */
extern id RXFold(id<NSFastEnumeration> enumeration, id initial, RXFoldBlock block);


#pragma mark Constructors

/**
 NSArray *RXConstructArray(id<RXTraversal> traversal)
 
 Constructs an array with the elements of the specified traversal. The enumeration's elements must not be nil.
 */
extern NSArray *RXConstructArray(id<RXTraversal> traversal);

/**
 NSSet *RXConstructSet(id<NSFastEnumeration>)
 
 Constructs a set with the elements of the specified enumeration. The enumeration's elements must not be nil.
 */
extern NSSet *RXConstructSet(id<NSFastEnumeration> enumeration);

/**
 NSDictionary *RXConstructDictionary(id<NSFastEnumeration> enumeration)
 
 Constructs a dictionary with the elements of the specified enumeration. The enumeration's elements must not be nil, and must conform to RXKeyValuePair.
 */
extern NSDictionary *RXConstructDictionary(id<NSFastEnumeration> enumeration);

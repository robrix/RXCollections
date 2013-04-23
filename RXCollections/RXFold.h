//  RXFold.h
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

typedef id (^RXFoldBlock)(id memo, id each); // memo is the initial value on the first invocation, and thereafter the value returned by the previous invocation of the block

/**
 id RXFold(id<NSFastEnumeration> enumeration, id initial, RXFoldBlock block)
 
 Folds a `enumeration` with `block`, using `initial` as the `memo` argument to block for the first element.
 */
extern id RXFold(id<NSFastEnumeration> enumeration, id initial, RXFoldBlock block);

typedef id (*RXFoldFunction)(id memo, id each); // memo is the initial value on the first invocation, and thereafter the value returned by the previous invocation of the function

/**
 id RXFoldF(id<NSFastEnumeration> enumeration, id initial, RXFoldFunction function);
 
 Folds a `enumeration` with `function`, using `initial` as the `memo` argument to block for the first element.
 */
extern id RXFoldF(id<NSFastEnumeration> enumeration, id initial, RXFoldFunction function);

#pragma mark Constructors

/**
 NSArray *RXConstructArray(id<NSObject, NSFastEnumeration> enumeration)
 
 Constructs an array with the elements of the specified traversal. The enumeration's elements must not be nil.
 */
extern NSArray *RXConstructArray(id<NSObject, NSFastEnumeration> enumeration);

/**
 NSSet *RXConstructSet(id<NSFastEnumeration> enumeration)
 
 Constructs a set with the elements of the specified enumeration. The enumeration's elements must not be nil.
 */
extern NSSet *RXConstructSet(id<NSFastEnumeration> enumeration);

/**
 NSDictionary *RXConstructDictionary(id<NSFastEnumeration> enumeration)
 
 Constructs a dictionary with the elements of the specified enumeration. The enumeration's elements must not be nil, and must conform to RXKeyValuePair.
 */
extern NSDictionary *RXConstructDictionary(id<NSFastEnumeration> enumeration);

/**
 RXTuple *RXConstructTuple(id<NSFastEnumeration> enumeration)
 
 Constructs a tuple with the elements of the specified enumeration. The enumeration's elements may be nil.
 */
@class RXTuple;
extern RXTuple *RXConstructTuple(id<NSFastEnumeration> enumeration);


#pragma mark Numerical

/**
 typedef id (^RXMinBlock)(id each);
 
 The type of a block which is used to return a value to be minimized (in terms of `NSComparisonResult`) across an enumeration.
 */
typedef id (^RXMinBlock)(id each);

/**
 id RXMin(id<NSFastEnumeration> enumeration, id initial, RXMinBlock minBlock)
 
 Finds the minimum value returned by `minBlock` across `enumeration`.
 
 If `initial` is nil, it is ignored. If it is non-nil it is the initial point of comparison.
 
 If `minBlock` is nil, each object is compared instead of the result of the block.
 */
extern id RXMin(id<NSFastEnumeration> enumeration, id initial, RXMinBlock minBlock);

/**
 typedef id (*RXMinFunction)(id each);
 
 The type of a function which is used to return a value to be minimized (in terms of `NSComparisonResult`) across an enumeration.
 */
typedef id (*RXMinFunction)(id each);

/**
 id RXMinF(id<NSFastEnumeration> enumeration, id initial, RXMinFunction minFunc)
 
 Finds the minimum value returned by `minFunc` across `enumeration`.
 
 If `initial` is nil, it is ignored. If it is non-nil it is the initial point of comparison.
 
 If `minBlock` is nil, each object is compared instead of the result of the block.
 */
extern id RXMinF(id<NSFastEnumeration> enumeration, id initial, RXMinFunction minFunc);

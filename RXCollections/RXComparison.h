//  RXComparison.h
//  Created by Rob Rix on 10/18/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

/**
 typedef id (^RXMinBlock)(id each)
 typedef id (*RXMinFunction)(id each)
 
 The type of a block or function which is used to return a value to be minimized (in terms of `NSComparisonResult`) across an enumeration.
 */
typedef id (^RXMinBlock)(id each, bool *stop);
typedef id (*RXMinFunction)(id each, bool *stop);

/**
 id RXMin(id<NSFastEnumeration> enumeration, id initial, RXMinBlock minBlock)
 id RXMinF(id<NSFastEnumeration> enumeration, id initial, RXMinFunction minFunc)
 
 Finds the minimum value returned by `minBlock` across `enumeration`.
 
 If `initial` is nil, it is ignored. If it is non-nil it is the initial point of comparison.
 
 If `minBlock` or `minFunction` is nil, the objects themselves are compared, rather than the result of the block or function.
 */
extern id RXMin(id<NSFastEnumeration> enumeration, id initial, RXMinBlock minBlock);
extern id RXMinF(id<NSFastEnumeration> enumeration, id initial, RXMinFunction minFunc);


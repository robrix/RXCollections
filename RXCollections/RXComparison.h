//  RXComparison.h
//  Created by Rob Rix on 10/18/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import <RXCollections/RXMap.h>

/**
 Finds the minimum value (as defined by `-compare:`) returned by \c block across \c enumeration.
 
 @param enumeration The enumeration to find a minimum across.
 @param initial The initial point of comparison. Ignored if nil.
 @param block A block returning the object to compare given each element of \c enumeration. Nil is treated as the identity block.
 */
extern id RXMin(id<NSFastEnumeration> enumeration, id initial, RXMapBlock block);

/**
 Finds the minimum value (as defined by `-compare:`) returned by \c function across \c enumeration.
 
 @param enumeration The enumeration to find a minimum across.
 @param initial The initial point of comparison. Ignored if nil.
 @param function A pointer to a function returning the object to compare given each element of \c enumeration. NULL is treated as the identity function.
 */
extern id RXMinF(id<NSFastEnumeration> enumeration, id initial, RXMapFunction function);

/**
 Finds the maximum value (as defined by `-compare:`) returned by \c block across \c enumeration.
 
 @param enumeration The enumeration to find a maximum across.
 @param initial The initial point of comparison. Ignored if nil.
 @param block A block returning the object to compare given each element of \c enumeration. Nil is treated as the identity block.
 */
extern id RXMax(id<NSFastEnumeration> enumeration, id initial, RXMapBlock block);

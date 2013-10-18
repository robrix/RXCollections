//  RXComparison.h
//  Created by Rob Rix on 10/18/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import <RXCollections/RXMap.h>

/**
 Finds the minimum value (as defined by `-compare:`) returned by \c block across \c enumeration.
 
 @param enumeration The enumeration to find a minimum across.
 @param block A block returning the object to compare given each element of \c enumeration. Nil is treated as the identity block.
 */
extern id RXMin(id<NSFastEnumeration> enumeration, RXMapBlock block);

/**
 Finds the minimum value (as defined by `-compare:`) returned by \c function across \c enumeration.
 
 @param enumeration The enumeration to find a minimum across.
 @param function A pointer to a function returning the object to compare given each element of \c enumeration. NULL is treated as the identity function.
 */
extern id RXMinF(id<NSFastEnumeration> enumeration, RXMapFunction function);

/**
 Finds the maximum value (as defined by `-compare:`) returned by \c block across \c enumeration.
 
 @param enumeration The enumeration to find a maximum across.
 @param block A block returning the object to compare given each element of \c enumeration. Nil is treated as the identity block.
 */
extern id RXMax(id<NSFastEnumeration> enumeration, RXMapBlock block);

/**
 Finds the maximum value (as defined by `-compare:`) returned by \c function across \c enumeration.
 
 @param enumeration The enumeration to find a maximum across.
 @param function A pointer to a function returning the object to compare given each element of \c enumeration. NULL is treated as the identity function.
 */
extern id RXMaxF(id<NSFastEnumeration> enumeration, RXMapFunction function);
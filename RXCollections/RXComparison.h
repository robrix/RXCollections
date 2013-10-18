//  RXComparison.h
//  Created by Rob Rix on 10/18/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import <RXCollections/RXMap.h>

/**
 Finds the minimum value returned by \c minBlock across \c enumeration.
 
 @param enumeration The enumeration to find a minimum across.
 @param initial The initial point of comparison. Ignored if nil.
 @param minBlock A block returning the object to compare given each element of \c enumeration. Nil is treated as the identity block.
 */
extern id RXMin(id<NSFastEnumeration> enumeration, id initial, RXMapBlock minBlock);

/**
 Finds the minimum value returned by \c minFunction across \c enumeration.
 
 @param enumeration The enumeration to find a minimum across.
 @param initial The initial point of comparison. Ignored if nil.
 @param minFunction A pointer to a function returning the object to compare given each element of \c enumeration. NULL is treated as the identity function.
 */
extern id RXMinF(id<NSFastEnumeration> enumeration, id initial, RXMapFunction minFunction);

//  Copyright (c) 2013 Rob Rix. All rights reserved.

@import Foundation;
#import <RXCollections/RXMap.h>

/**
 Finds the minimum value (as defined by \c -compare:) returned by \c block across \c enumeration.
 
 \param enumeration The enumeration to find a minimum across.
 \param block A block returning the object to compare given each element of \c enumeration. Nil is treated as the identity block.
 */
extern id RXMin(id<NSFastEnumeration> enumeration, RXMapBlock block);

/**
 Finds the maximum value (as defined by \c -compare:) returned by \c block across \c enumeration.
 
 \param enumeration The enumeration to find a maximum across.
 \param block A block returning the object to compare given each element of \c enumeration. Nil is treated as the identity block.
 */
extern id RXMax(id<NSFastEnumeration> enumeration, RXMapBlock block);

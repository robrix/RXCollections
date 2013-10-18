//  RXComparison.h
//  Created by Rob Rix on 10/18/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import <RXCollections/RXMap.h>

/**
 id RXMin(id<NSFastEnumeration> enumeration, id initial, RXMinBlock minBlock)
 id RXMinF(id<NSFastEnumeration> enumeration, id initial, RXMinFunction minFunc)
 
 Finds the minimum value returned by `minBlock` across `enumeration`.
 
 If `initial` is nil, it is ignored. If it is non-nil it is the initial point of comparison.
 
 If `minBlock` or `minFunction` is nil, the objects themselves are compared, rather than the result of the block or function.
 */
extern id RXMin(id<NSFastEnumeration> enumeration, id initial, RXMapBlock minBlock);
extern id RXMinF(id<NSFastEnumeration> enumeration, id initial, RXMapFunction minFunc);

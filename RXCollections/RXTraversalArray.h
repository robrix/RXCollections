//  RXTraversalArray.h
//  Created by Rob Rix on 2013-03-03.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

extern const NSUInteger RXTraversalArrayUnknownCount;

@interface RXTraversalArray : NSArray

+(instancetype)arrayWithFastEnumeration:(id<NSFastEnumeration>)enumeration;
+(instancetype)arrayWithFastEnumeration:(id<NSFastEnumeration>)enumeration count:(NSUInteger)count;

@end

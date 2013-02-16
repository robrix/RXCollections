//  RXLazyEnumeration.h
//  Created by Rob Rix on 2013-02-11.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

// not thread safe for NSFastEnumeration. just don't.

@interface RXLazyEnumeration : NSObject <RXTraversal>

+(instancetype)enumerationWithCollection:(id<NSFastEnumeration>)collection block:(id(^)(id))block;

@end

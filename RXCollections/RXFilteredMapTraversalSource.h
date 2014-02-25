//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXFilter.h>
#import <RXCollections/RXMap.h>

extern RXTraversalSource RXFilteredMapTraversalSource(id<NSObject, NSCopying, NSFastEnumeration> enumeration, RXFilterBlock filter, RXMapBlock map);

//  RXFilteredMapTraversalSource.h
//  Created by Rob Rix on 2013-04-14.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXFilter.h>
#import <RXCollections/RXMap.h>

extern RXTraversalSource RXFilteredMapTraversalSource(id<NSObject, NSFastEnumeration> enumeration, RXFilterBlock filter, RXMapBlock map);

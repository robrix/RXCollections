//  RXFilteredMapTraversalSource.m
//  Created by Rob Rix on 2013-04-14.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFilteredMapTraversalSource.h"
#import "RXTraversal.h"

RXTraversalSource RXFilteredMapTraversalSource(id<NSObject, NSCopying, NSFastEnumeration> enumeration, RXFilterBlock filter, RXMapBlock map) {
	id<RXTraversal> enumerationTraversal = RXTraversalWithEnumeration(enumeration);
	return ^bool(id<RXRefillableTraversal> traversal) {
		bool exhausted = enumerationTraversal.isExhausted;
		if (!exhausted) {
			id each = [enumerationTraversal nextObject];
			if(!filter || (filter(each, &exhausted) && !exhausted))
				[traversal addObject:map? map(each, &exhausted) : each];
		}
		return exhausted;
	};
}

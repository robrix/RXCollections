//  RXFilteredMapTraversalSource.m
//  Created by Rob Rix on 2013-04-14.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFilteredMapTraversalSource.h"

@interface RXFilteredMapTraversalSource ()
@property (nonatomic, strong) id<RXTraversal> traversal;
@property (nonatomic, copy) RXFilterBlock filter;
@property (nonatomic, copy) RXMapBlock map;
@end

@implementation RXFilteredMapTraversalSource

+(instancetype)sourceWithEnumeration:(id<NSObject, NSFastEnumeration>)enumeration filter:(RXFilterBlock)filter map:(RXMapBlock)map {
	RXFilteredMapTraversalSource *source = [self new];
	source.traversal = RXTraversalWithEnumeration(enumeration);
	source.filter = filter;
	source.map = map;
	return source;
}


-(void)refillTraversal:(id<RXRefillableTraversal>)traversal {
	[traversal refillWithBlock:^{
		bool exhausted = self.traversal.isExhausted;
		if (!exhausted) {
			id each = [self.traversal nextObject];
			if(!self.filter || (self.filter(each, &exhausted) && !exhausted))
				[traversal addObject:self.map? self.map(each, &exhausted) : each];
		}
		return exhausted;
	}];
}

@end

//  RXFilteredMapTraversalSource.m
//  Created by Rob Rix on 2013-04-14.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFilteredMapTraversalSource.h"

@interface RXFilteredMapTraversalSource ()
@property (nonatomic, strong, readwrite) id<RXTraversal> traversal;
@property (nonatomic, copy, readwrite) RXFilterBlock filter;
@property (nonatomic, copy, readwrite) RXMapBlock map;
@end

@implementation RXFilteredMapTraversalSource

+(instancetype)sourceWithTraversal:(id<RXTraversal>)traversal filter:(RXFilterBlock)filter map:(RXMapBlock)map {
	RXFilteredMapTraversalSource *source = [self new];
	source.traversal = traversal;
	source.filter = filter;
	source.map = map;
	return source;
}


-(void)populateTraversal:(id<RXBatchedTraversal>)traversal {
	[traversal populateWithBlock:^(bool *exhausted){
		id each = [(RXTraversal *)self.traversal consume:exhausted];
		if(!*exhausted && (!self.filter || self.filter(each)))
			[traversal produce:self.map? self.map(each) : each];
	}];
}

@end

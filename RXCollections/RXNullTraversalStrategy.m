//  RXNullTraversalStrategy.m
//  Created by Rob Rix on 2013-02-19.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXNullTraversalStrategy.h"

@implementation RXNullTraversalStrategy

-(void)enumerateObjects:(in __unsafe_unretained id [])internalObjects count:(inout NSUInteger *)internalObjectsCount intoObjects:(out __autoreleasing id [])externalObjects count:(inout NSUInteger *)externalObjectsCount {
	*externalObjectsCount = 0;
}

@end

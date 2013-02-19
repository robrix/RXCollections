//  RXIdentityTraversalStrategy.m
//  Created by Rob Rix on 2013-02-19.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXIdentityTraversalStrategy.h"

@implementation RXIdentityTraversalStrategy

-(void)enumerateObjects:(in __unsafe_unretained id [])internalObjects count:(inout NSUInteger *)internalObjectsCount intoObjects:(out __autoreleasing id [])externalObjects count:(inout NSUInteger *)externalObjectsCount {
	NSUInteger count = MIN(*internalObjectsCount, *externalObjectsCount);
	for (NSUInteger i = 0; i < count; i++) {
		externalObjects[i] = internalObjects[i];
	}
	*internalObjectsCount = *externalObjectsCount = count;
}

@end

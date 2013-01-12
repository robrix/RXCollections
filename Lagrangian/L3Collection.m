//  L3Collection.m
//  Created by Rob Rix on 2012-11-17.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3Collection.h"

#pragma mark Arrays

@implementation NSArray (L3Collection)

+(instancetype)l3_empty {
	return @[];
}

+(instancetype)l3_wrap:(id)element {
	NSParameterAssert(element != nil);
	
	return @[element];
}


-(instancetype)l3_appendCollection:(id<L3Collection>)other {
	NSParameterAssert([other isKindOfClass:[NSArray class]]);
	
	return [self arrayByAddingObjectsFromArray:(id)other];
}

@end


#pragma mark Sets

@implementation NSSet (L3Collection)

+(instancetype)l3_empty {
	return [NSSet set];
}

+(instancetype)l3_wrap:(id)element {
	NSParameterAssert(element != nil);
	
	return [NSSet setWithObject:element];
}


-(instancetype)l3_appendCollection:(id<L3Collection>)other {
	NSParameterAssert([other isKindOfClass:[NSSet class]]);
	
	return [self setByAddingObjectsFromSet:(id)other];
}

@end


#pragma mark Dictionaries

@implementation NSDictionary (L3Collection)

+(instancetype)l3_empty {
	return @{};
}

+(instancetype)l3_wrap:(id)element {
	NSParameterAssert(element != nil);
	
	// fixme: does this make any sense?
	return @{element: element};
}


-(instancetype)l3_appendCollection:(id<L3Collection>)other {
	NSMutableDictionary *all = [self mutableCopy];
	[all addEntriesFromDictionary:(id)other];
	return all;
}

@end

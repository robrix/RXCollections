//  RXCollection.m
//  Created by Rob Rix on 11-11-20.
//  Copyright (c) 2011 Rob Rix. All rights reserved.

#import "RXCollection.h"
#import "RXEnumerationTraversal.h"
#import "RXMappingTraversalStrategy.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXCollection");

@implementation NSArray (RXCollection)

-(id<RXCollection>)rx_emptyCollection {
	return [NSArray array];
}

-(instancetype)rx_append:(id)element {
	return element?
		[self arrayByAddingObject:element]
	:	self;
}

@end

@implementation NSMutableArray (RXCollection)

-(id<RXCollection>)rx_emptyCollection {
	return [NSMutableArray array];
}

-(instancetype)rx_append:(id)element {
	if (element)
		[self addObject:element];
	return self;
}

@end


@implementation NSSet (RXCollection)

-(id<RXCollection>)rx_emptyCollection {
	return [NSSet set];
}

-(instancetype)rx_append:(id)element {
	return element?
		[self setByAddingObject:element]
	:	self;
}

@end

@implementation NSMutableSet (RXCollection)

-(id<RXCollection>)rx_emptyCollection {
	return [NSMutableSet set];
}

-(instancetype)rx_append:(id)element {
	if (element)
		[self addObject:element];
	return self;
}

@end


@l3_suite("NSDictionary (RXCollection)");

@implementation NSDictionary (RXCollection)

-(id<RXCollection>)rx_emptyCollection {
	return [NSDictionary dictionary];
}

@l3_test("appends pairs by returning a new dictionary with the pair added") {
	NSDictionary *original = [NSDictionary dictionary];
	NSDictionary *appended = [original rx_append:[RXPair pairWithKey:@"x" value:@"y"]];
	l3_assert(appended, l3_not(original));
	l3_assert(appended[@"x"], @"y");
}

-(instancetype)rx_append:(id<RXKeyValuePair>)element {
	NSDictionary *dictionary = nil;
	if ([element respondsToSelector:@selector(key)] && [element respondsToSelector:@selector(value)]) {
		id<RXKeyValuePair> pair = element;
		NSMutableDictionary *mutableDictionary = [self mutableCopy];
		mutableDictionary[pair.key] = pair.value;
		dictionary = mutableDictionary;
	}
	return dictionary;
}

@end

@implementation NSMutableDictionary (RXCollection)

-(id<RXCollection>)rx_emptyCollection {
	return [NSMutableDictionary dictionary];
}

-(instancetype)rx_append:(id<RXKeyValuePair>)element {
	NSMutableDictionary *dictionary = nil;
	if ([element respondsToSelector:@selector(key)] && [element respondsToSelector:@selector(value)]) {
		id<RXKeyValuePair> pair = element;
		self[pair.key] = pair.value;
		dictionary = self;
	}
	return dictionary;
}

@end

//  RXCollection.m
//  Created by Rob Rix on 11-11-20.
//  Copyright (c) 2011 Rob Rix. All rights reserved.

#import "RXCollection.h"
#import "RXEnumerationTraversal.h"
#import "RXMappingTraversalStrategy.h"

#import <Lagrangian/Lagrangian.h>

#pragma mark Folds

@l3_suite("RXFold");

@l3_test("produces a result by recursively enumerating the collection") {
	NSString *result = RXFold((@[@"Quantum", @"Boomerang", @"Physicist", @"Cognizant"]), @"", ^(NSString * memo, NSString * each) {
		return [memo stringByAppendingString:each];
	});
	l3_assert(result, @"QuantumBoomerangPhysicistCognizant");
}

id RXFold(id<NSFastEnumeration> enumeration, id initial, RXFoldBlock block) {
	for (id each in enumeration) {
		initial = block(initial, each);
	}
	return initial;
}


#pragma mark Constructors

@l3_suite("RXConstructors");

@l3_test("construct arrays from enumerations") {
	l3_assert(RXConstructArray(@[@1, @2, @3]), l3_is(@[@1, @2, @3]));
}

NSArray *RXConstructArray(id<NSFastEnumeration> enumeration) {
	return RXFold(enumeration, [NSMutableArray array], ^(NSMutableArray *memo, id each) {
		[memo addObject:each];
		return memo;
	});
}

@l3_test("construct sets from enumerations") {
	l3_assert(RXConstructSet(@[@1, @2, @3]), l3_is([NSSet setWithObjects:@1, @2, @3, nil]));
}

NSSet *RXConstructSet(id<NSFastEnumeration> enumeration) {
	return RXFold(enumeration, [NSMutableSet set], ^(NSMutableSet *memo, id each) {
		[memo addObject:each];
		return memo;
	});
}

@l3_test("construct dictionaries from enumerations of pairs") {
	l3_assert(RXConstructDictionary(@[[RXPair pairWithKey:@1 value:@1], [RXPair pairWithKey:@2 value:@4], [RXPair pairWithKey:@3 value:@9]]), l3_is(@{@1: @1, @2: @4, @3: @9}));
}

NSDictionary *RXConstructDictionary(id<NSFastEnumeration> enumeration) {
	return RXFold(enumeration, [NSMutableDictionary new], ^(NSMutableDictionary *memo, id<RXKeyValuePair> each) {
		[memo setObject:each.value forKey:each.key];
		return memo;
	});
}


#pragma mark Collections

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

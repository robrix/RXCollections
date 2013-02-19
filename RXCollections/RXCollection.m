//  RXCollection.m
//  Created by Rob Rix on 11-11-20.
//  Copyright (c) 2011 Rob Rix. All rights reserved.

#import "RXCollection.h"
#import "RXEnumerationTraversal.h"
#import "RXFilteringTraversalStrategy.h"
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


#pragma mark Maps

@l3_suite("RXMap");

@l3_test("identity map block returns its argument") {
	l3_assert(RXIdentityMapBlock(@"Equestrian"), @"Equestrian");
}

RXMapBlock const RXIdentityMapBlock = ^(id x) {
	return x;
};


@l3_test("produces a collection of the same type as it enumerates when not given a destination") {
	l3_assert(RXMap([NSSet setWithObjects:@1, @2, nil], nil, RXIdentityMapBlock), l3_isKindOfClass([NSSet class]));
}

@l3_test("collects piecewise results into the given destination") {
	NSMutableSet *destination = [NSMutableSet setWithObject:@3];
	RXMap(@[@1, @2], destination, RXIdentityMapBlock);
	l3_assert(destination, l3_equals([NSSet setWithObjects:@1, @2, @3, nil]));
}

@l3_test("collects the piecewise results of its block") {
	l3_assert(RXMap(@[@"Hegemony", @"Maleficent"], nil, ^(NSString *each) {
		return [each stringByAppendingString:@"Superlative"];
	}), l3_equals(@[@"HegemonySuperlative", @"MaleficentSuperlative"]));
}

id<RXCollection> RXMap(id<RXCollection> collection, id<RXCollection> destination, RXMapBlock block) {
	destination = destination ?: [collection rx_emptyCollection];
	return RXFold(collection, destination, ^id(id previous, id each) {
		return [previous rx_append:block(each)];
	});
}


#pragma mark Lazy maps

id<RXTraversal> RXLazyMap(id<NSFastEnumeration> collection, RXMapBlock block) {
	return [RXEnumerationTraversal traversalWithEnumeration:collection strategy:[RXMappingTraversalStrategy strategyWithBlock:block]];
}


#pragma mark Filter

@l3_suite("RXFilter");

@l3_test("accept filters return YES") {
	l3_assert(RXAcceptFilterBlock(nil), YES);
}

RXFilterBlock const RXAcceptFilterBlock = ^bool(id each) {
	return YES;
};


@l3_test("reject filters return NO") {
	l3_assert(RXRejectFilterBlock(nil), NO);
}

RXFilterBlock const RXRejectFilterBlock = ^bool(id each) {
	return NO;
};

@l3_test("accept nil filters accept nil") {
	l3_assert(RXAcceptNilFilterBlock(nil), YES);
}

@l3_test("accept nil filters reject non-nil") {
	l3_assert(RXAcceptNilFilterBlock([NSObject new]), NO);
}

RXFilterBlock const RXAcceptNilFilterBlock = ^bool(id each) {
	return each == nil;
};

@l3_test("reject nil filters reject nil") {
	l3_assert(RXRejectNilFilterBlock(nil), NO);
}

@l3_test("reject nil filters accept non-nil") {
	l3_assert(RXRejectNilFilterBlock([NSObject new]), YES);
}

RXFilterBlock const RXRejectNilFilterBlock = ^bool(id each) {
	return each != nil;
};


@l3_test("filters a collection with the piecewise results of its block") {
	l3_assert(RXFilter(@[@"Ancestral", @"Philanthropic", @"Harbinger", @"Azimuth"], nil, ^bool(id each) {
		return [each hasPrefix:@"A"];
	}), l3_equals(@[@"Ancestral", @"Azimuth"]));
}

@l3_test("produces a collection of the same type as it enumerates when not given a destination") {
	l3_assert(RXFilter([NSSet setWithObject:@"x"], nil, RXAcceptFilterBlock), l3_isKindOfClass([NSSet class]));
}

@l3_test("collects filtered results into the given destination") {
	NSMutableSet *destination = [NSMutableSet setWithObject:@"Horological"];
	l3_assert(RXFilter(@[@"Psychosocial"], destination, RXAcceptFilterBlock), l3_equals([NSSet setWithObjects:@"Horological", @"Psychosocial", nil]));
}

id<RXCollection> RXFilter(id<RXCollection> collection, id<RXCollection> destination, RXFilterBlock block) {
	return RXMap(collection, destination, ^id(id each) {
		return block(each)? each : nil;
	});
}


@l3_test("produces a traversal of the elements of its enumeration which are matched by its block") {
	NSArray *filtered = RXConstructArray(RXLazyFilter(@[@"Sanguinary", @"Inspirational", @"Susurrus"], ^bool(NSString *each) {
		return [each hasPrefix:@"S"];
	}));
	l3_assert(filtered, l3_is(@[@"Sanguinary", @"Susurrus"]));
}

id<RXTraversal> RXLazyFilter(id<NSFastEnumeration> enumeration, RXFilterBlock block) {
	return [RXEnumerationTraversal traversalWithEnumeration:enumeration strategy:[RXFilteringTraversalStrategy strategyWithBlock:block]];
}


@l3_suite("RXLinearSearch");

@l3_test("returns the first encountered object for which its block returns true") {
	l3_assert(RXLinearSearch(@[@"Amphibious", @"Belligerent", @"Bizarre"], ^bool(id each) {
		return [each hasPrefix:@"B"];
	}), @"Belligerent");
}

id RXLinearSearch(id<RXTraversal> collection, RXFilterBlock block) {
	id needle = nil;
	for (needle in collection) {
		if (block(needle))
			break;
	}
	return needle;
}

RXLinearSearchFunction const RXDetect = RXLinearSearch;


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

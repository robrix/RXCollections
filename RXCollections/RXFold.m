//  RXFold.m
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFold.h"
#import "RXPair.h"
#import "RXEnumerationArray.h"
#import "RXTuple.h"

#import <Lagrangian/Lagrangian.h>

static RXFoldBlock RXFoldBlockWithFunction(RXFoldFunction function);

@l3_suite("RXFold");

static NSString *accumulator(NSString *memo, NSString *each, bool *stop) {
	return [memo stringByAppendingString:each];
}

@l3_test("produces a result by recursively enumerating the collection") {
	NSArray *collection = @[@"Quantum", @"Boomerang", @"Physicist", @"Cognizant"];
	l3_assert(RXFold(collection, @"", ^(NSString *memo, NSString *each, bool *stop) {
		return [memo stringByAppendingString:each];
	}), @"QuantumBoomerangPhysicistCognizant");

	l3_assert(RXFoldF(collection, @"", accumulator), @"QuantumBoomerangPhysicistCognizant");
}

id RXFold(id<NSFastEnumeration> enumeration, id initial, RXFoldBlock block) {
	for (id each in enumeration) {
		bool stop = NO;
		initial = block(initial, each, &stop);
		if (stop)
			break;
	}
	return initial;
}

id RXFoldF(id<NSFastEnumeration> enumeration, id initial, RXFoldFunction function) {
	return RXFold(enumeration, initial, RXFoldBlockWithFunction(function));
}


#pragma mark Constructors

@l3_suite("RXConstruct");

@l3_test("constructs arrays from traversals") {
	l3_assert(RXConstructArray(@[@1, @2, @3]), l3_is(@[@1, @2, @3]));
}

NSArray *RXConstructArray(id<NSObject, NSFastEnumeration> enumeration) {
	return [RXEnumerationArray arrayWithEnumeration:enumeration];
}

@l3_test("constructs sets from enumerations") {
	l3_assert(RXConstructSet(@[@1, @2, @3]), l3_is([NSSet setWithObjects:@1, @2, @3, nil]));
}

NSSet *RXConstructSet(id<NSFastEnumeration> enumeration) {
	return RXFold(enumeration, [NSMutableSet set], ^(NSMutableSet *memo, id each, bool *stop) {
		[memo addObject:each];
		return memo;
	});
}

@l3_test("construct dictionaries from enumerations of pairs") {
	l3_assert(RXConstructDictionary(@[[RXTuple tupleWithKey:@1 value:@1], [RXTuple tupleWithKey:@2 value:@4], [RXTuple tupleWithKey:@3 value:@9]]), l3_is(@{@1: @1, @2: @4, @3: @9}));
}

NSDictionary *RXConstructDictionary(id<NSFastEnumeration> enumeration) {
	return RXFold(enumeration, [NSMutableDictionary new], ^(NSMutableDictionary *memo, id<RXKeyValuePair> each, bool *stop) {
		[memo setObject:each.value forKey:each.key];
		return memo;
	});
}


RXTuple *RXConstructTuple(id<NSFastEnumeration> enumeration) {
	NSArray *objects = RXFold(enumeration, [NSMutableArray new], ^(NSMutableArray *memo, id each, bool *stop) {
		[memo addObject:each];
		return memo;
	});
	return [RXTuple tupleWithArray:objects];
}


static inline RXFoldBlock RXFoldBlockWithFunction(RXFoldFunction function) {
	return ^(id memo, id each, bool *stop){ return function(memo, each, stop); };
}

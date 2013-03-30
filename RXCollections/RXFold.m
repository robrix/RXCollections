//  RXFold.m
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFold.h"
#import "RXPair.h"
#import "RXTraversalArray.h"
#import "RXTuple.h"

#import <Lagrangian/Lagrangian.h>

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

@l3_suite("RXConstruct");

@l3_test("constructs arrays from traversals") {
	l3_assert(RXConstructArray(@[@1, @2, @3]), l3_is(@[@1, @2, @3]));
}

NSArray *RXConstructArray(id<RXTraversal> traversal) {
	return [RXTraversalArray arrayWithTraversal:traversal];
}

@l3_test("constructs sets from enumerations") {
	l3_assert(RXConstructSet(@[@1, @2, @3]), l3_is([NSSet setWithObjects:@1, @2, @3, nil]));
}

NSSet *RXConstructSet(id<NSFastEnumeration> enumeration) {
	return RXFold(enumeration, [NSMutableSet set], ^(NSMutableSet *memo, id each) {
		[memo addObject:each];
		return memo;
	});
}

@l3_test("construct dictionaries from enumerations of pairs") {
	l3_assert(RXConstructDictionary(@[[RXTuple tupleWithKey:@1 value:@1], [RXTuple tupleWithKey:@2 value:@4], [RXTuple tupleWithKey:@3 value:@9]]), l3_is(@{@1: @1, @2: @4, @3: @9}));
}

NSDictionary *RXConstructDictionary(id<NSFastEnumeration> enumeration) {
	return RXFold(enumeration, [NSMutableDictionary new], ^(NSMutableDictionary *memo, id<RXKeyValuePair> each) {
		[memo setObject:each.value forKey:each.key];
		return memo;
	});
}


@l3_suite("RXMin");

@l3_test("finds the minimum value among a collection") {
	l3_assert(RXMin(@[@3, @1, @2], nil, nil), @1);
}

@l3_test("considers the initial value if provided") {
	l3_assert(RXMin(@[@3, @1, @2], @0, nil), @0);
}

@l3_test("compares the value provided by the block if provided") {
	l3_assert(RXMin(@[@"123", @"1", @"12"], nil, ^(NSString *each) { return @(each.length); }), @1);
}

id RXMin(id<NSFastEnumeration> enumeration, id initial, RXMinBlock minBlock) {
	return RXFold(enumeration, initial, ^(id memo, id each) {
		id value = minBlock? minBlock(each) : each;
		return [memo compare:value] == NSOrderedAscending?
			memo
		:	value;
	});
}

//  RXComparison.m
//  Created by Rob Rix on 10/18/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXComparison.h"
#import "RXFold.h"

#import <Lagrangian/Lagrangian.h>

static RXMapBlock RXMapBlockWithFunction(RXMapFunction function);

#pragma mark Minima

@l3_suite("RXMin");

@l3_test("finds the minimum value among a collection") {
	l3_assert(RXMin(@[@3, @1, @2], nil, nil), @1);
	l3_assert(RXMinF(@[@3, @1, @2], nil, nil), @1);
}

@l3_test("considers the initial value if provided") {
	l3_assert(RXMin(@[@3, @1, @2], @0, nil), @0);
	l3_assert(RXMinF(@[@3, @1, @2], @0, nil), @0);
}

static id minLength(NSString *each, bool *stop) { return @(each.length); }

@l3_test("compares the value provided by the block if provided") {
	l3_assert(RXMin(@[@"123", @"1", @"12"], nil, ^(NSString *each, bool *stop) { return @(each.length); }), @1);
	l3_assert(RXMinF(@[@"123", @"1", @"12"], nil, minLength), @1);
}

id RXMin(id<NSFastEnumeration> enumeration, id initial, RXMapBlock block) {
	return RXFold(enumeration, initial, ^(id memo, id each, bool *stop) {
		id value = block? block(each, stop) : each;
		return [memo compare:value] == NSOrderedAscending?
			memo
		:	value;
	});
}

id RXMinF(id<NSFastEnumeration> enumeration, id initial, RXMapFunction function) {
	return RXMin(enumeration, initial, function? RXMapBlockWithFunction(function) : nil);
}


#pragma mark Maxima

@l3_suite("RXMax");

@l3_test("finds the maximum value among a collection") {
	l3_assert(RXMax(@[@3, @1, @2], nil, nil), @3);
}

@l3_test("considers the initial value if provided") {
	l3_assert(RXMax(@[@3, @1, @2], @4, nil), @4);
}


id RXMax(id<NSFastEnumeration> enumeration, id initial, RXMapBlock block) {
	return RXFold(enumeration, initial, ^(id memo, id each, bool *stop) {
		id value = block? block(each, stop) : each;
		return [memo compare:value] == NSOrderedDescending?
			memo
		:	value;
	});
}


#pragma mark Function pointer support

static inline RXMapBlock RXMapBlockWithFunction(RXMapFunction function) {
	return ^(id each, bool *stop){ return function(each, stop); };
}

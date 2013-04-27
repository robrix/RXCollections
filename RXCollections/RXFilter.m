//  RXFilter.m
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFilter.h"
#import "RXFilteredMapTraversalSource.h"
#import "RXFold.h"
#import "RXMap.h"

#import <Lagrangian/Lagrangian.h>

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


static bool itemsPrefixedWithA(id each) {
	return [each hasPrefix:@"A"];
}

@l3_test("filters a collection with the piecewise results of its block") {
	l3_assert(RXConstructArray(RXFilter(@[@"Ancestral", @"Philanthropic", @"Harbinger", @"Azimuth"], ^bool(id each) {
		return [each hasPrefix:@"A"];
	})), l3_equals(@[@"Ancestral", @"Azimuth"]));
	
	l3_assert(RXConstructArray(RXFilterF(@[@"Ancestral", @"Philanthropic", @"Harbinger", @"Azimuth"], itemsPrefixedWithA)), l3_equals(@[@"Ancestral", @"Azimuth"]));
}

static bool itemsPrefixedWithS(id each) {
	return [each hasPrefix:@"S"];
}

@l3_test("produces a traversal of the elements of its enumeration which are matched by its block") {
	NSArray *unfiltered = @[@"Sanguinary", @"Inspirational", @"Susurrus"];
	NSArray *filtered = RXConstructArray(RXFilter(unfiltered, ^bool(NSString *each) {
		return [each hasPrefix:@"S"];
	}));
	l3_assert(filtered, l3_is(@[@"Sanguinary", @"Susurrus"]));
	
	filtered = RXConstructArray(RXFilterF(unfiltered, itemsPrefixedWithS));
	l3_assert(filtered, l3_is(@[@"Sanguinary", @"Susurrus"]));
}

id<RXTraversal> RXFilter(id<NSObject, NSFastEnumeration> enumeration, RXFilterBlock block) {
	return RXTraversalWithSource([RXFilteredMapTraversalSource sourceWithEnumeration:enumeration filter:block map:nil]);
}


@l3_suite("RXLinearSearch");

static bool itemIsPrefixedWithB(id each) {
	return [each hasPrefix:@"B"];
}

@l3_test("returns the first encountered object for which its block returns true") {
	l3_assert(RXLinearSearch(@[@"Amphibious", @"Belligerent", @"Bizarre"], ^bool(id each) {
		return [each hasPrefix:@"B"];
	}), @"Belligerent");
	
	l3_assert(RXLinearSearchF(@[@"Amphibious", @"Belligerent", @"Bizarre"], itemIsPrefixedWithB), @"Belligerent");
}

id RXLinearSearch(id<NSFastEnumeration> collection, RXFilterBlock block) {
	id needle = nil;
	for (needle in collection) {
		if (block(needle))
			break;
	}
	return needle;
}

id (* const RXDetect)(id<NSFastEnumeration>, RXFilterBlock) = RXLinearSearch;

@l3_suite("RXFilterF");

@l3_test("accept filter returns YES") {
	l3_assert(RXAcceptFilterFunction(nil), YES);
}

bool RXAcceptFilterFunction(id each) {
	return YES;
}

@l3_test("reject filter returns NO") {
	l3_assert(RXRejectFilterFunction(nil), NO);
}

bool RXRejectFilterFunction(id each) {
	return NO;
}

@l3_test("accept nil filters accept nil") {
	l3_assert(RXAcceptNilFilterFunction(nil), YES);
}

@l3_test("accept nil filters reject non-nil") {
	l3_assert(RXAcceptNilFilterFunction([NSObject new]), NO);
}

bool RXAcceptNilFilterFunction(id each) {
	return each == nil;
}

@l3_test("reject nil filters reject nil") {
	l3_assert(RXRejectNilFilterFunction(nil), NO);
}

@l3_test("reject nil filters accept non-nil") {
	l3_assert(RXRejectNilFilterFunction([NSObject new]), YES);
}

bool RXRejectNilFilterFunction(id each) {
	return each != nil;
}

id<RXTraversal> RXFilterF(id<NSObject, NSFastEnumeration> enumeration, RXFilterFunction function) {
	return RXFilter(enumeration, ^bool(id each) {
		return function(each);
	});
}

id RXLinearSearchF(id<NSFastEnumeration> collection, RXFilterFunction function) {
	return RXLinearSearch(collection, ^bool(id each) {
		return function(each);
	});
}

id (* const RXDetectF)(id<NSFastEnumeration>, RXFilterFunction) = RXLinearSearchF;

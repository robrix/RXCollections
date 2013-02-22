//  RXFilter.m
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFilter.h"
#import "RXEnumerationTraversal.h"
#import "RXFilteringTraversalStrategy.h"
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

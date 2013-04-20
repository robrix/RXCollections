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


@l3_test("filters a collection with the piecewise results of its block") {
	l3_assert(RXConstructArray(RXFilter(@[@"Ancestral", @"Philanthropic", @"Harbinger", @"Azimuth"], ^bool(id each) {
		return [each hasPrefix:@"A"];
	})), l3_equals(@[@"Ancestral", @"Azimuth"]));
}

@l3_test("produces a traversal of the elements of its enumeration which are matched by its block") {
	NSArray *filtered = RXConstructArray(RXFilter(@[@"Sanguinary", @"Inspirational", @"Susurrus"], ^bool(NSString *each) {
		return [each hasPrefix:@"S"];
	}));
	l3_assert(filtered, l3_is(@[@"Sanguinary", @"Susurrus"]));
}

id<RXTraversal> RXFilter(id<NSObject, NSFastEnumeration> enumeration, RXFilterBlock block) {
	return RXTraversalWithSource([RXFilteredMapTraversalSource sourceWithEnumeration:enumeration filter:block map:nil]);
}


@l3_suite("RXLinearSearch");

@l3_test("returns the first encountered object for which its block returns true") {
	l3_assert(RXLinearSearch(@[@"Amphibious", @"Belligerent", @"Bizarre"], ^bool(id each) {
		return [each hasPrefix:@"B"];
	}), @"Belligerent");
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

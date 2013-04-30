//  RXFilter.m
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFilter.h"
#import "RXFilteredMapTraversalSource.h"
#import "RXFold.h"
#import "RXMap.h"

#import <Lagrangian/Lagrangian.h>

static RXFilterBlock RXFilterBlockWithFunction(RXFilterFunction function);

@l3_suite("RXFilter");

@l3_test("accept filters return YES") {
	__block bool stop = NO;
	l3_assert(RXAcceptFilterBlock(nil, &stop), YES);
	l3_assert(RXAcceptFilterFunction(nil, &stop), YES);
}

RXFilterBlock const RXAcceptFilterBlock = ^bool(id each, bool *stop) {
	return YES;
};

bool RXAcceptFilterFunction(id each, bool *stop) {
	return YES;
}


@l3_test("reject filters return NO") {
	__block bool stop = NO;
	l3_assert(RXRejectFilterBlock(nil, &stop), NO);
	l3_assert(RXRejectFilterFunction(nil, &stop), NO);
}

RXFilterBlock const RXRejectFilterBlock = ^bool(id each, bool *stop) {
	return NO;
};

bool RXRejectFilterFunction(id each, bool *stop) {
	return NO;
}


@l3_test("accept nil filters accept nil") {
	__block bool stop = NO;
	l3_assert(RXAcceptNilFilterBlock(nil, &stop), YES);
	l3_assert(RXAcceptNilFilterFunction(nil, &stop), YES);
}

@l3_test("accept nil filters reject non-nil") {
	__block bool stop = NO;
	l3_assert(RXAcceptNilFilterBlock([NSObject new], &stop), NO);
	l3_assert(RXAcceptNilFilterFunction([NSObject new], &stop), NO);
}

RXFilterBlock const RXAcceptNilFilterBlock = ^bool(id each, bool *stop) {
	return each == nil;
};

bool RXAcceptNilFilterFunction(id each, bool *stop) {
	return each == nil;
}


@l3_test("reject nil filters reject nil") {
	__block bool stop = NO;
	l3_assert(RXRejectNilFilterBlock(nil, &stop), NO);
	l3_assert(RXRejectNilFilterFunction(nil, &stop), NO);
}

@l3_test("reject nil filters accept non-nil") {
	__block bool stop = NO;
	l3_assert(RXRejectNilFilterBlock([NSObject new], &stop), YES);
	l3_assert(RXRejectNilFilterFunction([NSObject new], &stop), YES);
}

RXFilterBlock const RXRejectNilFilterBlock = ^bool(id each, bool *stop) {
	return each != nil;
};

bool RXRejectNilFilterFunction(id each, bool *stop) {
	return each != nil;
}


static bool itemsPrefixedWithA(id each, bool *stop) {
	return [each hasPrefix:@"A"];
}

@l3_test("filters a collection with the piecewise results of its block") {
	NSArray *unfiltered = @[@"Ancestral", @"Philanthropic", @"Harbinger", @"Azimuth"];
	l3_assert(RXConstructArray(RXFilter(unfiltered, ^bool(id each, bool *stop) {
		return [each hasPrefix:@"A"];
	})), l3_equals(@[@"Ancestral", @"Azimuth"]));
	
	l3_assert(RXConstructArray(RXFilterF(unfiltered, itemsPrefixedWithA)), l3_equals(@[@"Ancestral", @"Azimuth"]));
}

static bool itemsPrefixedWithS(id each, bool *stop) {
	return [each hasPrefix:@"S"];
}

@l3_test("produces a traversal of the elements of its enumeration which are matched by its block") {
	NSArray *unfiltered = @[@"Sanguinary", @"Inspirational", @"Susurrus"];
	NSArray *filtered = RXConstructArray(RXFilter(unfiltered, ^bool(NSString *each, bool *stop) {
		return [each hasPrefix:@"S"];
	}));
	l3_assert(filtered, l3_is(@[@"Sanguinary", @"Susurrus"]));
	
	filtered = RXConstructArray(RXFilterF(unfiltered, itemsPrefixedWithS));
	l3_assert(filtered, l3_is(@[@"Sanguinary", @"Susurrus"]));
}

id<RXTraversal> RXFilter(id<NSObject, NSFastEnumeration> enumeration, RXFilterBlock block) {
	return RXTraversalWithSource([RXFilteredMapTraversalSource sourceWithEnumeration:enumeration filter:block map:nil]);
}

id<RXTraversal> RXFilterF(id<NSObject, NSFastEnumeration> enumeration, RXFilterFunction function) {
	return RXFilter(enumeration, RXFilterBlockWithFunction(function));
}


@l3_suite("RXLinearSearch");

static bool itemIsPrefixedWithB(id each, bool *stop) {
	return [each hasPrefix:@"B"];
}

@l3_test("returns the first encountered object for which its block returns true") {
	l3_assert(RXLinearSearch(@[@"Amphibious", @"Belligerent", @"Bizarre"], ^bool(id each, bool *stop) {
		return [each hasPrefix:@"B"];
	}), @"Belligerent");
	
	l3_assert(RXLinearSearchF(@[@"Amphibious", @"Belligerent", @"Bizarre"], itemIsPrefixedWithB), @"Belligerent");
}

id RXLinearSearch(id<NSFastEnumeration> collection, RXFilterBlock block) {
	return RXFold(collection, nil, ^(id memo, id each, bool *stop) {
		return block(each, stop) && (*stop = YES)?
			each
		:	nil;
	});
}

id RXLinearSearchF(id<NSFastEnumeration> collection, RXFilterFunction function) {
	return RXLinearSearch(collection, RXFilterBlockWithFunction(function));
}

id (* const RXDetect)(id<NSFastEnumeration>, RXFilterBlock) = RXLinearSearch;
id (* const RXDetectF)(id<NSFastEnumeration>, RXFilterFunction) = RXLinearSearchF;


static RXFilterBlock RXFilterBlockWithFunction(RXFilterFunction function) {
	return ^(id each, bool *stop){ return function(each, stop); };
};

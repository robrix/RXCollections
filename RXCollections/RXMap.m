//  RXMap.m
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXMap.h"
#import "RXEnumerationTraversal.h"
#import "RXFold.h"
#import "RXMappingTraversalStrategy.h"

#import <Lagrangian/Lagrangian.h>

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


id<RXTraversal> RXLazyMap(id<NSFastEnumeration> collection, RXMapBlock block) {
	return [RXEnumerationTraversal traversalWithEnumeration:collection strategy:[RXMappingTraversalStrategy strategyWithBlock:block]];
}

//  RXMap.m
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXMap.h"
#import "RXFilteredMapTraversalSource.h"
#import "RXFold.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXMap");

@l3_test("identity map block returns its argument") {
	l3_assert(RXIdentityMapBlock(@"Equestrian"), @"Equestrian");
}

RXMapBlock const RXIdentityMapBlock = ^(id x) {
	return x;
};


@l3_test("collects the piecewise results of its block") {
	l3_assert(RXConstructArray(RXMap(@[@"Hegemony", @"Maleficent"], ^(NSString *each) {
		return [each stringByAppendingString:@"Superlative"];
	})), l3_equals(@[@"HegemonySuperlative", @"MaleficentSuperlative"]));
}

id<RXTraversal> RXMap(id<NSFastEnumeration> enumeration, RXMapBlock block) {
	return [RXTraversal traversalWithSource:[RXFilteredMapTraversalSource sourceWithTraversal:[RXTraversal traversalWithEnumeration:enumeration] filter:nil map:block]];
}

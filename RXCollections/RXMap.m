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

id<RXTraversal> RXMap(id<NSObject, NSFastEnumeration> enumeration, RXMapBlock block) {
	return RXTraversalWithSource([RXFilteredMapTraversalSource sourceWithEnumeration:enumeration filter:nil map:block]);
}

@l3_suite("RXMapF");

@l3_test("identity map function returns its argument") {
	l3_assert(RXIdentityMapFunction(@"Equestrian"), @"Equestrian");
}

RXMapFunction const RXIdentityMapFunction = (id x) {
	return x;
}

@l3_test("collects the piecewise results of its function") {
	NSString *accumulate(NSString *each) {
		return [each stringByAppendingString:@"Superlative"];
	}
	l3_assert(RXConstructArray(RXMapF(@[@"Hegemony", @"Maleficent"], accumulate)), l3_equals(@[@"HegemonySuperlative", @"MaleficentSuperlative"]));
}

id<RXTraversal> RXMapF(id<NSObject, NSFastEnumeration> enumeration, RXMapFunction function) {
	return RXMap(enumeration, ^id(id each) {
		return function(each);
	});
}

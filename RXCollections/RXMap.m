//  RXMap.m
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXMap.h"
#import "RXFilteredMapTraversalSource.h"
#import "RXFold.h"

#import <Lagrangian/Lagrangian.h>

static inline RXMapBlock RXMapBlockWithFunction(RXMapFunction function);

@l3_suite("RXMap");

@l3_test("identity map block returns its argument") {
	l3_assert(RXIdentityMapBlock(@"Equestrian"), @"Equestrian");
	l3_assert(RXIdentityMapFunction(@"Equestrian"), @"Equestrian");
}

RXMapBlock const RXIdentityMapBlock = ^(id x) {
	return x;
};

id RXIdentityMapFunction(id x) {
	return x;
}


static NSString *accumulate(NSString *each) {
	return [each stringByAppendingString:@"Superlative"];
}

@l3_test("collects the piecewise results of its block") {
	l3_assert(RXConstructArray(RXMapF(@[@"Hegemony", @"Maleficent"], accumulate)), (@[@"HegemonySuperlative", @"MaleficentSuperlative"]));
	
	l3_assert(RXConstructArray(RXMap(@[@"Hegemony", @"Maleficent"], ^(NSString *each) {
		return [each stringByAppendingString:@"Superlative"];
	})), (@[@"HegemonySuperlative", @"MaleficentSuperlative"]));
}

id<RXTraversal> RXMap(id<NSObject, NSFastEnumeration> enumeration, RXMapBlock block) {
	return RXTraversalWithSource([RXFilteredMapTraversalSource sourceWithEnumeration:enumeration filter:nil map:block]);
}

id<RXTraversal> RXMapF(id<NSObject, NSFastEnumeration> enumeration, RXMapFunction function) {
	return RXMap(enumeration, RXMapBlockWithFunction(function));
}


@l3_suite("RXMapBlockWithFunction");

@l3_test("identity function to block returns an identity block") {
	NSObject *object = [NSObject new];
	l3_assert(RXMapBlockWithFunction(RXIdentityMapFunction)(object), object);
}

static inline RXMapBlock RXMapBlockWithFunction(RXMapFunction function) {
	return ^(id each) {
		return function(each);
	};
}

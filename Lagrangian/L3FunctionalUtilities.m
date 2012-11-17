//  L3FunctionalUtilities.m
//  Created by Rob Rix on 2012-11-13.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3Collection.h"
#import "L3FunctionalUtilities.h"
#import "Lagrangian.h"

@l3_suite("Folds");

@l3_test("sequentially produce an object from a collection given a block") {
	NSString *concatenation = L3Fold(@[@"a", @"b", @"c"], @"", ^id(id accumulation, id element) { return [accumulation stringByAppendingString:element]; });
	l3_assert(concatenation, l3_equals(@"abc"));
}

id L3Fold(id<NSFastEnumeration> collection, id accumulation, L3FoldBlock block) {
	for (id element in collection) {
		accumulation = block(accumulation, element);
	}
	return accumulation;
}


@l3_suite("Maps");

@l3_test("produce a collection by mapping a block over a collection") {
	NSArray *appended = L3Map(@[@"a", @"b", @"c"], ^id(id element) {
		return [element stringByAppendingString:@"0"];
	});
	l3_assert(appended, l3_equals(@[@"a0", @"b0", @"c0"]));
}

id L3Map(id<L3Collection> collection, L3MapBlock block) {
	return L3Fold(collection, [[collection class] l3_empty], ^id(id<L3Collection> accumulation, id element) {
		return [accumulation l3_appendCollection:[[collection class] l3_wrap:block(element)]];
	});
}
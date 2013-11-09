//  RXComparison.m
//  Created by Rob Rix on 10/18/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXComparison.h"
#import "RXFold.h"

#import <Lagrangian/Lagrangian.h>

static RXMapBlock RXMapBlockWithFunction(RXMapFunction function);

#pragma mark Minima

l3_addTestSubjectTypeWithFunction(RXMin)

l3_test(&RXMin, ^{
	l3_expect(RXMin(@[@3, @1, @2], nil)).to.equal(@1);
	l3_expect(RXMin(@[@"123", @"1", @"12"], ^(NSString *each, bool *stop) { return @(each.length); })).to.equal(@"1");
})

id RXMin(id<NSFastEnumeration> enumeration, RXMapBlock block) {
	__block id minimum;
	return RXFold(enumeration, nil, ^(id memo, id each, bool *stop) {
		id value = block? block(each, stop) : each;
		NSComparisonResult order = [minimum compare:value];
		minimum = order == NSOrderedAscending? minimum : value;
		return order == NSOrderedAscending?
			memo
		:	each;
	});
}

id RXMinF(id<NSFastEnumeration> enumeration, RXMapFunction function) {
	return RXMin(enumeration, function? RXMapBlockWithFunction(function) : nil);
}


#pragma mark Maxima

l3_test(&RXMax, ^{
	l3_expect(RXMax(@[@3, @1, @2], nil)).to.equal(@3);
	l3_expect(RXMax(@[@"123", @"1", @"12"], ^(NSString *each, bool *stop) { return @(each.length); })).to.equal(@"123");
})

id RXMax(id<NSFastEnumeration> enumeration, RXMapBlock block) {
	__block id maximum;
	return RXFold(enumeration, nil, ^(id memo, id each, bool *stop) {
		id value = block? block(each, stop) : each;
		NSComparisonResult order = [maximum compare:value];
		maximum = order == NSOrderedDescending? maximum : value;
		return order == NSOrderedDescending?
			memo
		:	each;
	});
}

id RXMaxF(id<NSFastEnumeration> enumeration, RXMapFunction function) {
	return RXMax(enumeration, function? RXMapBlockWithFunction(function) : nil);
}


#pragma mark Function pointer support

static inline RXMapBlock RXMapBlockWithFunction(RXMapFunction function) {
	return ^(id each, bool *stop){ return function(each, stop); };
}

//  RXFilter.m
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFilter.h"
#import "RXFilteredMapTraversalSource.h"
#import "RXFold.h"
#import "RXMap.h"

#import <Lagrangian/Lagrangian.h>

l3_addTestSubjectTypeWithBlock(RXFilterBlock)
l3_addTestSubjectTypeWithFunction(RXFilter)
l3_addTestSubjectTypeWithFunction(RXLinearSearch)

l3_test(RXAcceptFilterBlock, ^{
	bool stop = NO;
	l3_expect(RXAcceptFilterBlock(nil, &stop)).to.equal(@YES);
})

RXFilterBlock const RXAcceptFilterBlock = ^bool(id each, bool *stop) {
	return YES;
};


l3_test(RXRejectFilterBlock, ^{
	bool stop = NO;
	l3_expect(RXRejectFilterBlock(nil, &stop)).to.equal(@NO);
})

RXFilterBlock const RXRejectFilterBlock = ^bool(id each, bool *stop) {
	return NO;
};


l3_test(RXAcceptNilFilterBlock, ^{
	bool stop = NO;
	l3_expect(RXAcceptNilFilterBlock(nil, &stop)).to.equal(@YES);
	l3_expect(RXAcceptNilFilterBlock([NSObject new], &stop)).to.equal(@NO);
})

RXFilterBlock const RXAcceptNilFilterBlock = ^bool(id each, bool *stop) {
	return each == nil;
};


l3_test(RXRejectNilFilterBlock, ^{
	bool stop = NO;
	l3_expect(RXRejectNilFilterBlock(nil, &stop)).to.equal(@NO);
	l3_expect(RXRejectNilFilterBlock([NSObject new], &stop)).to.equal(@YES);
})

RXFilterBlock const RXRejectNilFilterBlock = ^bool(id each, bool *stop) {
	return each != nil;
};


l3_test(&RXFilter, ^{
	NSArray *unfiltered = @[@"Ancestral", @"Philanthropic", @"Harbinger", @"Azimuth"];
	NSArray *filtered = RXConstructArray(RXFilter(unfiltered, ^bool(id each, bool *stop) {
		return [each hasPrefix:@"A"];
	}));
	l3_expect(filtered).to.equal(@[@"Ancestral", @"Azimuth"]);
	
	NSArray *stopped = RXConstructArray(RXFilter(unfiltered, ^bool(id each, bool *stop) {
		*stop = YES;
		return YES;
	}));
	l3_expect(stopped).to.equal(@[]);
})

id<RXTraversal> RXFilter(id<NSObject, NSFastEnumeration> enumeration, RXFilterBlock block) {
	return RXTraversalWithSource(RXFilteredMapTraversalSource(enumeration, block, nil));
}


l3_test(&RXLinearSearch, ^{
	id found = RXLinearSearch(@[@"Amphibious", @"Belligerent", @"Bizarre"], ^bool(id each, bool *stop) {
		return [each hasPrefix:@"B"];
	});
	l3_expect(found).to.equal(@"Belligerent");
})

id RXLinearSearch(id<NSFastEnumeration> collection, RXFilterBlock block) {
	return RXFold(collection, nil, ^(id memo, id each, bool *stop) {
		return block(each, stop) && (*stop = YES)?
			each
		:	nil;
	});
}

id (* const RXDetect)(id<NSFastEnumeration>, RXFilterBlock) = RXLinearSearch;

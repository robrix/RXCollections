//  RXFilter.m
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFilter.h"
#import "RXFilteredMapTraversalSource.h"
#import "RXFold.h"
#import "RXMap.h"

#import <Lagrangian/Lagrangian.h>

static RXFilterBlock RXFilterBlockWithFunction(RXFilterFunction function);

L3_OVERLOADABLE L3Test *L3TestDefine(NSString *file, NSUInteger line, RXFilterBlock subject, L3TestBlock block) {
	return [L3Test testWithSourceReference:L3SourceReferenceCreate(nil, file, line, nil, L3TestSymbolForFunction((L3FunctionTestSubject)L3TestFunctionForBlock((L3BlockTestSubject)subject))) block:block];
}

L3_OVERLOADABLE L3Test *L3TestDefine(NSString *file, NSUInteger line, id<RXTraversal>(*subject)(id<NSObject, NSFastEnumeration>, RXFilterBlock), L3TestBlock block) {
	return [L3Test testWithSourceReference:L3SourceReferenceCreate(nil, file, line, nil, L3TestSymbolForFunction((L3FunctionTestSubject)subject)) block:block];
}

L3_OVERLOADABLE L3Test *L3TestDefine(NSString *file, NSUInteger line, id(*subject)(id<NSFastEnumeration>, RXFilterBlock), L3TestBlock block) {
	return [L3Test testWithSourceReference:L3SourceReferenceCreate(nil, file, line, nil, L3TestSymbolForFunction((L3FunctionTestSubject)subject)) block:block];
}

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


static bool itemsPrefixedWithA(id each, bool *stop) {
	return [each hasPrefix:@"A"];
}

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

id<RXTraversal> RXFilterF(id<NSObject, NSFastEnumeration> enumeration, RXFilterFunction function) {
	return RXFilter(enumeration, RXFilterBlockWithFunction(function));
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

id RXLinearSearchF(id<NSFastEnumeration> collection, RXFilterFunction function) {
	return RXLinearSearch(collection, RXFilterBlockWithFunction(function));
}

id (* const RXDetect)(id<NSFastEnumeration>, RXFilterBlock) = RXLinearSearch;
id (* const RXDetectF)(id<NSFastEnumeration>, RXFilterFunction) = RXLinearSearchF;


static inline RXFilterBlock RXFilterBlockWithFunction(RXFilterFunction function) {
	return ^(id each, bool *stop){ return function(each, stop); };
};

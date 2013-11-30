//  RXFilter.m
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFilter.h"
#import "RXFastEnumerator.h"
#import "RXFold.h"
#import "RXMap.h"

#import <Lagrangian/Lagrangian.h>

@interface RXFilterEnumerator : RXEnumerator <RXEnumerator>

-(instancetype)initWithEnumerator:(id<RXEnumerator>)enumerator block:(RXFilterBlock)block;

@property (nonatomic, readonly) id<RXEnumerator> enumerator;
@property (nonatomic, copy, readonly) RXFilterBlock block;

@end

l3_addTestSubjectTypeWithBlock(RXFilterBlock)
l3_addTestSubjectTypeWithFunction(RXFilter)
l3_addTestSubjectTypeWithFunction(RXLinearSearch)

l3_test(RXAcceptFilterBlock, ^{
	l3_expect(RXAcceptFilterBlock(nil)).to.equal(@YES);
})

RXFilterBlock const RXAcceptFilterBlock = ^bool(id each) {
	return YES;
};


l3_test(RXRejectFilterBlock, ^{
	l3_expect(RXRejectFilterBlock(nil)).to.equal(@NO);
})

RXFilterBlock const RXRejectFilterBlock = ^bool(id each) {
	return NO;
};


l3_test(RXAcceptNilFilterBlock, ^{
	l3_expect(RXAcceptNilFilterBlock(nil)).to.equal(@YES);
	l3_expect(RXAcceptNilFilterBlock([NSObject new])).to.equal(@NO);
})

RXFilterBlock const RXAcceptNilFilterBlock = ^bool(id each) {
	return each == nil;
};


l3_test(RXRejectNilFilterBlock, ^{
	l3_expect(RXRejectNilFilterBlock(nil)).to.equal(@NO);
	l3_expect(RXRejectNilFilterBlock([NSObject new])).to.equal(@YES);
})

RXFilterBlock const RXRejectNilFilterBlock = ^bool(id each) {
	return each != nil;
};


l3_test(&RXFilter, ^{
	NSArray *unfiltered = @[@"Ancestral", @"Philanthropic", @"Harbinger", @"Azimuth"];
	NSArray *filtered = RXConstructArray(RXFilter(unfiltered, ^bool(id each) {
		return [each hasPrefix:@"A"];
	}));
	l3_expect(filtered).to.equal(@[@"Ancestral", @"Azimuth"]);
})

id<RXEnumerator> RXFilter(id<NSObject, NSFastEnumeration> enumeration, RXFilterBlock block) {
	return [[RXFilterEnumerator alloc] initWithEnumerator:RXEnumeratorWithEnumeration(enumeration) block:block];
}


l3_test(&RXLinearSearch, ^{
	id found = RXLinearSearch(@[@"Amphibious", @"Belligerent", @"Bizarre"], ^bool(id each) {
		return [each hasPrefix:@"B"];
	});
	l3_expect(found).to.equal(@"Belligerent");
})

id RXLinearSearch(id<NSFastEnumeration> collection, RXFilterBlock block) {
	return RXFold(collection, nil, ^(id memo, id each) {
		return block(each)?
			each
		:	memo;
	});
}

id (* const RXDetect)(id<NSFastEnumeration>, RXFilterBlock) = RXLinearSearch;


@implementation RXFilterEnumerator

-(instancetype)initWithEnumerator:(id<RXEnumerator>)enumerator block:(RXFilterBlock)block {
	NSParameterAssert(enumerator != nil);
	NSParameterAssert(block != nil);
	
	if ((self = [super init])) {
		_enumerator = enumerator;
		_block = [block copy];
	}
	return self;
}


-(id)nextObject {
	id object;
	while ((object = [self.enumerator nextObject]) && !self.block(object));
	return object;
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	RXFilterEnumerator *copy = [super copyWithZone:zone];
	copy->_block = [_block copy];
	return copy;
}

@end

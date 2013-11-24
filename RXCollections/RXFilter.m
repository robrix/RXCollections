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

id<RXEnumerator> RXFilter(id<NSObject, NSFastEnumeration> enumeration, RXFilterBlock block) {
	return [[RXFilterEnumerator alloc] initWithEnumerator:RXEnumeratorWithEnumeration(enumeration) block:block];
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


@implementation RXFilterEnumerator {
	bool _stop;
}

@synthesize currentObject = _currentObject;

-(instancetype)initWithEnumerator:(id<RXEnumerator>)enumerator block:(RXFilterBlock)block {
	NSParameterAssert(enumerator != nil);
	NSParameterAssert(block != nil);
	
	if ((self = [super init])) {
		_enumerator = enumerator;
		_block = [block copy];
	}
	return self;
}


-(void)_consumeRejectedObjects {
	while (!_stop && !self.enumerator.isEmpty && ![self _objectIsAccepted:self.enumerator.currentObject]) {
		[self.enumerator consumeCurrentObject];
	}
}

-(bool)_objectIsAccepted:(id)object {
	return self.block(object, &_stop) && !_stop;
}

-(bool)isEmpty {
	[self _consumeRejectedObjects];
	return _stop || self.enumerator.isEmpty;
}

-(id)currentObject {
	[self _consumeRejectedObjects];
	return self.enumerator.currentObject;
}

-(void)consumeCurrentObject {
	[self.enumerator consumeCurrentObject];
}

@end

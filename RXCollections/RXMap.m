//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXMap.h"
#import "RXFilteredMapTraversalSource.h"
#import "RXFold.h"

#import <Lagrangian/Lagrangian.h>

static inline RXMapBlock RXMapBlockWithFunction(RXMapFunction function);

l3_addTestSubjectTypeWithBlock(RXMapBlock);

l3_test(RXIdentityMapBlock, ^{
	bool stop = NO;
	l3_expect(RXIdentityMapBlock(@"Equestrian", &stop)).to.equal(@"Equestrian");
})

RXMapBlock const RXIdentityMapBlock = ^(id x, bool *stop) {
	return x;
};


l3_addTestSubjectTypeWithFunction(RXMap);

l3_test(&RXMap, ^{
	id mapped = RXConstructArray(RXMap(@[@"Hegemony", @"Maleficent"], ^(NSString *each, bool *stop) {
		return [each stringByAppendingString:@"Superlative"];
	}));
	l3_expect(mapped).to.equal(@[@"HegemonySuperlative", @"MaleficentSuperlative"]);
})

id<RXTraversal> RXMap(id<NSObject, NSCopying, NSFastEnumeration> enumeration, RXMapBlock block) {
	return RXTraversalWithSource(RXFilteredMapTraversalSource(enumeration, nil, block));
}

id<RXTraversal> RXMapF(id<NSObject, NSCopying, NSFastEnumeration> enumeration, RXMapFunction function) {
	return RXMap(enumeration, RXMapBlockWithFunction(function));
}


l3_addTestSubjectTypeWithFunction(RXMapBlockWithFunction);

static id identityFunction(id each, bool *stop) {
	return each;
}

l3_test(&RXMapBlockWithFunction, ^{
	NSObject *object = [NSObject new];
	bool stop = NO;
	l3_expect(RXMapBlockWithFunction(identityFunction)(object, &stop)).to.equal(object);
})

static inline RXMapBlock RXMapBlockWithFunction(RXMapFunction function) {
	return ^(id each, bool *stop) {
		return function(each, stop);
	};
}

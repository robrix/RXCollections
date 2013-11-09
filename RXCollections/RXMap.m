//  RXMap.m
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXMap.h"
#import "RXFilteredMapTraversalSource.h"
#import "RXFold.h"

#import <Lagrangian/Lagrangian.h>

static inline RXMapBlock RXMapBlockWithFunction(RXMapFunction function);

L3_OVERLOADABLE L3Test *L3TestDefine(NSString *file, NSUInteger line, RXMapBlock subject, L3TestBlock block) {
	return [L3Test testWithSourceReference:L3SourceReferenceCreate(nil, file, line, nil, L3TestSymbolForFunction((L3FunctionTestSubject)L3TestFunctionForBlock((L3BlockTestSubject)subject))) block:block];
}

L3_OVERLOADABLE L3Test *L3TestDefine(NSString *file, NSUInteger line, id<RXTraversal>(*subject)(id<NSObject, NSFastEnumeration>, RXMapBlock), L3TestBlock block) {
	return [L3Test testWithSourceReference:L3SourceReferenceCreate(nil, file, line, nil, L3TestSymbolForFunction((L3FunctionTestSubject)subject)) block:block];
}

L3_OVERLOADABLE L3Test *L3TestDefine(NSString *file, NSUInteger line, RXMapBlock(*subject)(RXMapFunction), L3TestBlock block) {
	return [L3Test testWithSourceReference:L3SourceReferenceCreate(nil, file, line, nil, L3TestSymbolForFunction((L3FunctionTestSubject)subject)) block:block];
}

l3_test(RXIdentityMapBlock, ^{
	bool stop = NO;
	l3_expect(RXIdentityMapBlock(@"Equestrian", &stop)).to.equal(@"Equestrian");
})

RXMapBlock const RXIdentityMapBlock = ^(id x, bool *stop) {
	return x;
};


static NSString *accumulate(NSString *each, bool *stop) {
	return [each stringByAppendingString:@"Superlative"];
}

l3_test(&RXMap, ^{
	id mapped = RXConstructArray(RXMap(@[@"Hegemony", @"Maleficent"], ^(NSString *each, bool *stop) {
		return [each stringByAppendingString:@"Superlative"];
	}));
	l3_expect(mapped).to.equal(@[@"HegemonySuperlative", @"MaleficentSuperlative"]);
})

id<RXTraversal> RXMap(id<NSObject, NSFastEnumeration> enumeration, RXMapBlock block) {
	return RXTraversalWithSource(RXFilteredMapTraversalSource(enumeration, nil, block));
}

id<RXTraversal> RXMapF(id<NSObject, NSFastEnumeration> enumeration, RXMapFunction function) {
	return RXMap(enumeration, RXMapBlockWithFunction(function));
}


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

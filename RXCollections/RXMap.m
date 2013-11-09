//  RXMap.m
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXMap.h"
#import "RXFilteredMapTraversalSource.h"
#import "RXFold.h"

#import <Lagrangian/Lagrangian.h>

l3_addTestSubjectTypeWithBlock(RXMapBlock)
l3_addTestSubjectTypeWithFunction(RXMap)

l3_test(RXIdentityMapBlock, ^{
	bool stop = NO;
	l3_expect(RXIdentityMapBlock(@"Equestrian", &stop)).to.equal(@"Equestrian");
})

RXMapBlock const RXIdentityMapBlock = ^(id x, bool *stop) {
	return x;
};


l3_test(&RXMap, ^{
	id mapped = RXConstructArray(RXMap(@[@"Hegemony", @"Maleficent"], ^(NSString *each, bool *stop) {
		return [each stringByAppendingString:@"Superlative"];
	}));
	l3_expect(mapped).to.equal(@[@"HegemonySuperlative", @"MaleficentSuperlative"]);
})

id<RXTraversal> RXMap(id<NSObject, NSFastEnumeration> enumeration, RXMapBlock block) {
	return RXTraversalWithSource(RXFilteredMapTraversalSource(enumeration, nil, block));
}

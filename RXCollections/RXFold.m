//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFold.h"
#import "RXPair.h"
#import "RXEnumerationArray.h"
#import "RXTuple.h"
#import <Lagrangian/Lagrangian.h>

l3_test("RXFold", ^{
	NSArray *collection = @[@"Quantum", @"Boomerang", @"Physicist", @"Cognizant"];
	
	id folded = RXFold(collection, @"", ^(NSString *memo, NSString *each) {
		return [memo stringByAppendingString:each];
	});
	l3_expect(folded).to.equal(@"QuantumBoomerangPhysicistCognizant");
})

id RXFold(id<NSObject, NSCopying, NSFastEnumeration> enumeration, id initial, RXFoldBlock block) {
	for (id each in enumeration) {
		initial = block(initial, each);
		if (!initial)
			break;
	}
	return initial;
}


#pragma mark Constructors

l3_test("RXConstructArray", ^{
	id constructed = RXConstructArray(@[@1, @2, @3]);
	l3_expect(constructed).to.equal(@[@1, @2, @3]);
})

NSArray *RXConstructArray(id<NSObject, NSCopying, NSFastEnumeration> enumeration) {
	return [RXEnumerationArray arrayWithEnumeration:enumeration];
}

l3_test("RXConstructSet", ^{
	id constructed = RXConstructSet(@[@1, @2, @3]);
	l3_expect(constructed).to.equal([NSSet setWithObjects:@1, @2, @3, nil]);
})

NSSet *RXConstructSet(id<NSObject, NSCopying, NSFastEnumeration> enumeration) {
	return RXFold(enumeration, [NSMutableSet set], ^(NSMutableSet *memo, id each) {
		[memo addObject:each];
		return memo;
	});
}

l3_test("RXConstructDictionary", ^{
	id constructed = RXConstructDictionary(@[[RXTuple tupleWithKey:@1 value:@1], [RXTuple tupleWithKey:@2 value:@4], [RXTuple tupleWithKey:@3 value:@9]]);
	l3_expect(constructed).to.equal(@{@1: @1, @2: @4, @3: @9});
})

NSDictionary *RXConstructDictionary(id<NSObject, NSCopying, NSFastEnumeration> enumeration) {
	return RXFold(enumeration, [NSMutableDictionary new], ^(NSMutableDictionary *memo, id<RXKeyValuePair> each) {
		[memo setObject:each.value forKey:each.key];
		return memo;
	});
}


RXTuple *RXConstructTuple(id<NSObject, NSCopying, NSFastEnumeration> enumeration) {
	NSArray *objects = RXFold(enumeration, [NSMutableArray new], ^(NSMutableArray *memo, id each) {
		[memo addObject:each];
		return memo;
	});
	return [RXTuple tupleWithArray:objects];
}

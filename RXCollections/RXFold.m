//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXFold.h"
#import "RXPair.h"
#import "RXEnumerationArray.h"
#import "RXTuple.h"

#import <Lagrangian/Lagrangian.h>

l3_test("RXFold", ^{
	NSArray *collection = @[@"Quantum", @"Boomerang", @"Physicist", @"Cognizant"];
	
	id folded = RXFold(collection, @"", ^(NSString *memo, NSString *each, bool *stop) {
		return [memo stringByAppendingString:each];
	});
	l3_expect(folded).to.equal(@"QuantumBoomerangPhysicistCognizant");
})

id RXFold(id<NSFastEnumeration> enumeration, id initial, RXFoldBlock block) {
	for (id each in enumeration) {
		bool stop = NO;
		initial = block(initial, each, &stop);
		if (stop)
			break;
	}
	return initial;
}


#pragma mark Constructors

l3_test("RXConstructArray", ^{
	id constructed = RXConstructArray(@[@1, @2, @3]);
	l3_expect(constructed).to.equal(@[@1, @2, @3]);
})

NSArray *RXConstructArray(id<NSObject, NSFastEnumeration> enumeration) {
	return [RXEnumerationArray arrayWithEnumeration:enumeration];
}

l3_test("RXConstructSet", ^{
	id constructed = RXConstructSet(@[@1, @2, @3]);
	l3_expect(constructed).to.equal([NSSet setWithObjects:@1, @2, @3, nil]);
})

NSSet *RXConstructSet(id<NSFastEnumeration> enumeration) {
	return RXFold(enumeration, [NSMutableSet set], ^(NSMutableSet *memo, id each, bool *stop) {
		[memo addObject:each];
		return memo;
	});
}

l3_test("RXConstructDictionary", ^{
	id constructed = RXConstructDictionary(@[[RXTuple tupleWithKey:@1 value:@1], [RXTuple tupleWithKey:@2 value:@4], [RXTuple tupleWithKey:@3 value:@9]]);
	l3_expect(constructed).to.equal(@{@1: @1, @2: @4, @3: @9});
})

NSDictionary *RXConstructDictionary(id<NSFastEnumeration> enumeration) {
	return RXFold(enumeration, [NSMutableDictionary new], ^(NSMutableDictionary *memo, id<RXKeyValuePair> each, bool *stop) {
		[memo setObject:each.value forKey:each.key];
		return memo;
	});
}


RXTuple *RXConstructTuple(id<NSFastEnumeration> enumeration) {
	NSArray *objects = RXFold(enumeration, [NSMutableArray new], ^(NSMutableArray *memo, id each, bool *stop) {
		[memo addObject:each];
		return memo;
	});
	return [RXTuple tupleWithArray:objects];
}

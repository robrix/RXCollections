//  RXCollection.m
//  Created by Rob Rix on 11-11-20.
//  Copyright (c) 2011 Rob Rix. All rights reserved.

#import "RXCollection.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXFold");

#pragma mark Folds

@l3_test("produces a result by recursively enumerating the collection") {
	NSString *result = RXFold((@[@"Quantum", @"Boomerang", @"Physicist", @"Cognizant"]), @"", ^(NSString * memo, NSString * each) {
		return [memo stringByAppendingString:each];
	});
	l3_assert(result, @"QuantumBoomerangPhysicistCognizant");
}

id RXFold(id<NSFastEnumeration> collection, id initial, RXFoldBlock block) {
	for (id each in collection) {
		initial = block(initial, each);
	}
	return initial;
}


#pragma mark Maps

@l3_suite("RXMap");

@l3_test("identity map block returns its argument") {
	l3_assert(RXIdentityMapBlock(@"Equestrian"), @"Equestrian");
}

RXMapBlock const RXIdentityMapBlock = ^(id x) {
	return x;
};


@l3_test("produces a collection of the same type as it enumerates when not given a destination") {
	l3_assert(RXMap([NSSet setWithObjects:@1, @2, nil], nil, RXIdentityMapBlock), l3_isKindOfClass([NSSet class]));
}

@l3_test("collects piecewise results into the given destination") {
	NSMutableSet *destination = [NSMutableSet setWithObject:@3];
	RXMap(@[@1, @2], destination, RXIdentityMapBlock);
	l3_assert(destination, l3_equals([NSSet setWithObjects:@1, @2, @3, nil]));
}

@l3_test("collects the piecewise results of its block") {
	l3_assert(RXMap(@[@"Hegemony", @"Maleficent"], nil, ^(NSString *each) {
		return [each stringByAppendingString:@"Superlative"];
	}), l3_equals(@[@"HegemonySuperlative", @"MaleficentSuperlative"]));
}

id<RXCollection> RXMap(id<RXCollection> collection, id<RXCollection> destination, RXMapBlock block) {
	destination = destination ?: [collection rx_emptyCollection];
	return RXFold(collection, destination, ^id(id previous, id each) {
		return [previous rx_append:block(each)];
	});
}


#pragma mark Filter

@l3_suite("RXFilter");

@l3_test("accept filters return YES") {
	l3_assert(RXAcceptFilterBlock(nil), YES);
}

RXFilterBlock const RXAcceptFilterBlock = ^bool(id each) {
	return YES;
};


@l3_test("reject filters return NO") {
	l3_assert(RXRejectFilterBlock(nil), NO);
}

RXFilterBlock const RXRejectFilterBlock = ^bool(id each) {
	return NO;
};


@l3_test("filters a collection with the piecewise results of its block") {
	l3_assert(RXFilter(@[@"Ancestral", @"Philanthropic", @"Harbinger", @"Azimuth"], nil, ^bool(id each) {
		return [each hasPrefix:@"A"];
	}), l3_equals(@[@"Ancestral", @"Azimuth"]));
}

@l3_test("produces a collection of the same type as it enumerates when not given a destination") {
	l3_assert(RXFilter([NSSet setWithObject:@"x"], nil, RXAcceptFilterBlock), l3_isKindOfClass([NSSet class]));
}

@l3_test("collects filtered results into the given destination") {
	NSMutableSet *destination = [NSMutableSet setWithObject:@"Horological"];
	l3_assert(RXFilter(@[@"Psychosocial"], destination, RXAcceptFilterBlock), l3_equals([NSSet setWithObjects:@"Horological", @"Psychosocial", nil]));
}

id<RXCollection> RXFilter(id<RXCollection> collection, id<RXCollection> destination, RXFilterBlock block) {
	return RXMap(collection, destination, ^id(id each) {
		return block(each)? each : nil;
	});
}


@l3_suite("L3Detect");

@l3_test("returns the first encountered object for which its block returns true") {
	l3_assert(RXDetect(@[@"Amphibious", @"Belligerent", @"Bizarre"], ^bool(id each) {
		return [each hasPrefix:@"B"];
	}), @"Belligerent");
}

// fixme; this iterates every element in the collection; it should short-circuit break and return
id RXDetect(id<NSFastEnumeration> collection, RXFilterBlock block) {
	return RXFold(collection, nil, ^id(id memo, id each) {
		return memo ?: (block(each)? each : nil);
	});
}


#pragma mark Collections

@l3_suite("RXCollection");

@implementation NSObject (RXCollection)

@l3_test("implements fast enumeration over individual objects") {
	NSMutableArray *enumerated = [NSMutableArray new];
	id subject = [NSObject new];
	for (id object in subject) {
		[enumerated addObject:object];
	}
	l3_assert(enumerated, @[subject]);
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	buffer[0] = self;
	state->itemsPtr = buffer;
	state->mutationsPtr = &state->extra[0];
	return !state->state++;
}


-(id<RXCollection>)rx_emptyCollection {
	return self;
}

-(instancetype)rx_append:(id)element {
	return element;
}

@end


@implementation NSArray (RXCollection)

-(id<RXCollection>)rx_emptyCollection {
	return [NSArray array];
}

-(instancetype)rx_append:(id)element {
	return element?
		[self arrayByAddingObject:element]
	:	self;
}

@end

@implementation NSMutableArray (RXCollection)

-(id<RXCollection>)rx_emptyCollection {
	return [NSMutableArray array];
}

-(instancetype)rx_append:(id)element {
	if (element)
		[self addObject:element];
	return self;
}

@end


@implementation NSSet (RXCollection)

-(id<RXCollection>)rx_emptyCollection {
	return [NSSet set];
}

-(instancetype)rx_append:(id)element {
	return element?
		[self setByAddingObject:element]
	:	self;
}

@end

@implementation NSMutableSet (RXCollection)

-(id<RXCollection>)rx_emptyCollection {
	return [NSMutableSet set];
}

-(instancetype)rx_append:(id)element {
	if (element)
		[self addObject:element];
	return self;
}

@end


@implementation NSDictionary (RXCollection)

-(id<RXCollection>)rx_emptyCollection {
	return [NSDictionary dictionary];
}

-(instancetype)rx_append:(id)element {
	// make a new dictionary
	// interpret element as a pair?
//	if (element)
//		self[element.key] = element.value;
	return self;
}

@end

@implementation NSMutableDictionary (RXCollection)

-(id<RXCollection>)rx_emptyCollection {
	return [NSMutableDictionary dictionary];
}

-(instancetype)rx_append:(id)element {
	// interpret element as a pair?
//	if (element)
//		self[element.key] = element.value;
	return self;
}

@end

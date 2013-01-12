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

RXMapBlock const RXIdentityMapBlock = ^(id x) {
	return x;
};

id<RXCollection> RXMap(id<RXCollection> collection, id<RXCollection> destination, RXMapBlock block) {
	destination = destination ?: [collection rx_emptyCollection];
	return RXFold(collection, destination, ^id(id previous, id each) {
		return [previous rx_append:block(each)];
	});
}


#pragma mark Filter

RXFilterBlock const RXAcceptFilterBlock = ^bool(id each) {
	return YES;
};

RXFilterBlock const RXRejectFilterBlock = ^bool(id each) {
	return NO;
};

id<RXCollection> RXFilter(id<RXCollection> collection, id<RXCollection> destination, RXFilterBlock block) {
	return RXMap(collection, destination, ^id(id each) {
		return block(each)? each : nil;
	});
}

// fixme; this still iterates every element in the collection; it should short-circuit break and return
id RXDetect(id<NSFastEnumeration> collection, RXFilterBlock block) {
	return RXFold(collection, nil, ^id(id memo, id each) {
		return memo ?: (block(each)? each : nil);
	});
}


#pragma mark Collections

@implementation NSObject (RXCollection)

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

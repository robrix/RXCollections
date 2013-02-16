//  RXLazyEnumeration.m
//  Created by Rob Rix on 2013-02-11.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXLazyEnumeration.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXLazyEnumeration");

typedef struct RXLazyEnumerationState {
	unsigned long hasEnumerated;
	__unsafe_unretained id *itemsPtr;
	unsigned long *mutationsPtr;
	unsigned long countOfLastEnumeration;
	unsigned long countConsumedOfLastEnumeration;
} RXLazyEnumerationState;

@interface RXLazyEnumeration ()

@property (nonatomic, strong, readonly) id<NSFastEnumeration> collection;
@property (nonatomic, copy, readonly) id(^block)(id);

@property (nonatomic, strong) NSMutableDictionary *collectionStatesByEnumerationStateAddresses;

@end

@implementation RXLazyEnumeration

+(instancetype)enumerationWithCollection:(id<NSFastEnumeration>)collection block:(id(^)(id))block {
	return [[self alloc] initWithCollection:collection block:block];
}

-(instancetype)initWithCollection:(id<NSFastEnumeration>)collection block:(id(^)(id))block {
	NSParameterAssert(collection != nil);
	NSParameterAssert(block != nil);
	
	if ((self = [super init])) {
		_collection = collection;
		_block = [block copy];
		
		_collectionStatesByEnumerationStateAddresses = [NSMutableDictionary new];
	}
	return self;
}


#pragma mark NSFastEnumeration

@l3_test("maps while it is enumerated") {
	NSArray *adjectives = @[@"quick", @"pointed"];
	NSMutableArray *adverbs = [NSMutableArray new];
	
	for (NSString *adverb in [RXLazyEnumeration enumerationWithCollection:adjectives block:^(NSString *adjective) {
		return [adjective stringByAppendingString:@"ly"];
	}]) {
		[adverbs addObject:adverb];
	}
	l3_assert(adverbs, l3_is(@[@"quickly", @"pointedly"]));
}

@l3_test("maps correctly over collections of more items than the for(in) buffer") {
	NSArray *lowercase = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z"];
	
	NSMutableArray *uppercase = [NSMutableArray new];
	for (NSString *upper in [RXLazyEnumeration enumerationWithCollection:lowercase block:^(NSString *lower) {
		return [lower uppercaseString];
	}]) {
		[uppercase addObject:upper];
	}
	
	l3_assert(uppercase, l3_is(@[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"]));
}

@l3_test("maps with reentrancy over collections of more items than the for(in) buffer") {
	NSArray *alphabet = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z"];
	id<NSFastEnumeration> toUpper = [RXLazyEnumeration enumerationWithCollection:alphabet block:^(NSString * letter) {
		return [letter uppercaseString];
	}];
	
	NSMutableArray *combos = [NSMutableArray new];
	for (NSString *first in toUpper) {
		for (NSString *second in toUpper) {
			[combos addObject:[first stringByAppendingString:second]];
		}
	}
	
	l3_assert(combos.count, alphabet.count * alphabet.count);
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)fastEnumerationState objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	RXLazyEnumerationState *state = (RXLazyEnumerationState *)fastEnumerationState;
	id<NSCopying> key = @((uintptr_t)fastEnumerationState);
	NSMutableData *collectionStateData = self.collectionStatesByEnumerationStateAddresses[key];
	NSFastEnumerationState *collectionState = collectionStateData.mutableBytes ?: &(NSFastEnumerationState){};
	
	// throw out old state if we find ourselves in a new one; e.g. the for(in) around us hit a break; and we never returned 0
	if (!state->hasEnumerated) {
		state->hasEnumerated = YES;
		state->mutationsPtr = &state->hasEnumerated;
	}
	
	__unsafe_unretained id objects[len];
	// do the next enumeration of the source collection if we have already exhausted the previous enumeration's returned objects
	if (state->countOfLastEnumeration == state->countConsumedOfLastEnumeration) {
		state->countOfLastEnumeration = [self.collection countByEnumeratingWithState:collectionState objects:objects count:len];
		state->countConsumedOfLastEnumeration = 0;
	}
	
	unsigned long countConsumedOfCurrentEnumeration = MIN(len, state->countOfLastEnumeration - state->countConsumedOfLastEnumeration);
	
	// enumerate and map, or, if there is nothing to enumerate, flush the stored collection state
	if (countConsumedOfCurrentEnumeration > 0) {
		state->itemsPtr = buffer;
		for (NSUInteger i = 0; i < countConsumedOfCurrentEnumeration; i++) {
			__autoreleasing id *mapped = (__autoreleasing id *)(void *)&state->itemsPtr[i];
			*mapped = self.block(collectionState->itemsPtr[i + state->countConsumedOfLastEnumeration]);
		}
		
		state->countConsumedOfLastEnumeration += countConsumedOfCurrentEnumeration;
		
		if (!collectionStateData)
			self.collectionStatesByEnumerationStateAddresses[key] = [NSMutableData dataWithBytes:collectionState length:sizeof *collectionState];
	} else {
		[self.collectionStatesByEnumerationStateAddresses removeObjectForKey:key];
	}
	
	return countConsumedOfCurrentEnumeration;
}

@end

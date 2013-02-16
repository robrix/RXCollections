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

@property (nonatomic, assign) NSFastEnumerationState collectionState;

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

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)fastEnumerationState objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	RXLazyEnumerationState *state = (RXLazyEnumerationState *)fastEnumerationState;
	// throw out old state if we find ourselves in a new one; e.g. the for(in) around us hit a break; and we never returned 0
	if (!state->hasEnumerated) {
		state->hasEnumerated = YES;
		state->mutationsPtr = &state->hasEnumerated;
		self.collectionState = (NSFastEnumerationState){};
	}
	
	__unsafe_unretained id objects[len];
	// do the next enumeration of the source collection if we have already exhausted the previous enumeration's returned objects
	if (state->countOfLastEnumeration == state->countConsumedOfLastEnumeration) {
		state->countOfLastEnumeration = [self.collection countByEnumeratingWithState:&_collectionState objects:objects count:len];
		state->countConsumedOfLastEnumeration = 0;
	}
	unsigned long countConsumedOfCurrentEnumeration = MIN(len, state->countOfLastEnumeration - state->countConsumedOfLastEnumeration);
	
	state->itemsPtr = buffer;
	for (NSUInteger i = 0; i < countConsumedOfCurrentEnumeration; i++) {
		__autoreleasing id *mapped = (__autoreleasing id *)(void *)&state->itemsPtr[i];
		*mapped = self.block(self.collectionState.itemsPtr[i + state->countConsumedOfLastEnumeration]);
	}
	
	state->countConsumedOfLastEnumeration += countConsumedOfCurrentEnumeration;
	
	return countConsumedOfCurrentEnumeration;
}

@end

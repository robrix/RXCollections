//  RXSequenceEnumerator.m
//  Created by Rob Rix on 2013-03-31.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXSequenceEnumerator.h"

#import <Lagrangian/Lagrangian.h>

@l3_suite("RXSequenceEnumerator");

@implementation RXSequenceEnumerator

+(instancetype)enumeratorWithSequence:(id<RXSequence>)sequence filterBlock:(RXFilterBlock)filterBlock mapBlock:(RXMapBlock)mapBlock {
	return [[self alloc] initWithSequence:sequence filterBlock:filterBlock mapBlock:mapBlock];
}

-(instancetype)initWithSequence:(id<RXSequence>)sequence filterBlock:(RXFilterBlock)filterBlock mapBlock:(RXMapBlock)mapBlock {
	if ((self = [super init])) {
		_sequence = sequence;
		_filterBlock = [filterBlock copy];
		_mapBlock = [mapBlock copy];
	}
	return self;
}


@l3_test("does not retrieve any objects if it is empty") {
	RXSequenceEnumerator *enumerator = [RXSequenceEnumerator enumeratorWithSequence:@[] filterBlock:nil mapBlock:nil];
	RXSequenceEnumerationState *state = [RXSequenceEnumerationState new];
	l3_assert([enumerator retrieveObjectsWithState:state], NO);
}

-(bool)retrieveObjectsWithState:(RXSequenceEnumerationState *)state {
	RXSequenceEnumerationState *internalState = state.context ?: (state.context = [RXSequenceEnumerationState new]);
	/*
	 with each in input up to (output buffer length):
		 if filter(each):
			produce map(each)
	 */
	const bool moreComing = [self.sequence retrieveObjectsWithState:internalState];
	const NSUInteger maximum = MIN(state.capacity, internalState.count);
	NSUInteger count = 0;
	const bool hasFilter = self.filterBlock != nil;
	const bool hasMap = self.mapBlock != nil;
	for (NSUInteger i = 0; i < maximum; i++) {
		id each = internalState.objects[i];
		if (!hasFilter || self.filterBlock(each))
			state.objectBuffer[count++] = hasMap? self.mapBlock(each) : each;
	}
	state.count = count;
	
	return moreComing;
}

@end

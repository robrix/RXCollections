//  RXSequence.h
//  Created by Rob Rix on 2013-03-30.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

/*
 
 goals:
 
 - efficient
	- return batches of objects
	- good locality of reference
 - composable
	- easy to delegate sequencing to other sequences
	- easy to wrap/adapt other sequences (e.g. map), potentially multiple other sequences (interleaving, concatenating)
 - lazy
	- does work in response to requests for its results
 - potentially asynchronous?
	- use case
		- live stream of parsed JSON objects from some network connection
			- network connection returns data
			- data gets buffered, split on null bytes
			- chunks get parsed as JSON
			- JSON gets fed into UI
			- none of the above happens on the main thread
 - usable for a variety of tasks
	- input streaming
	- input buffering/splitting
	- parsing
	- general maps and folds
 - should it encompass consumers as well?
 
 map(input, block):
 
 lazily(input, ^(id each){ return block(each); })
 
 
 traversing a sequence is traversing a series of fixed-size arrays:
	[[0..15], [16..31], [32..47], [48..63]]
 
 */

@class RXSequenceEnumerationState;

@protocol RXSequence <NSObject>

//-(bool)populateArray:(id<RXFixedArray>)array context:(id __strong *)context;
//@property (nonatomic, readonly, assign) NSUInteger count;

-(bool)retrieveObjectsWithState:(RXSequenceEnumerationState *)state;

// size required for state?
// class required for state?

@end


extern const NSUInteger RXSequenceEnumerationStateObjectBufferCapacity;

@interface RXSequenceEnumerationState : NSObject

@property (nonatomic, assign) id const *objects;
@property (nonatomic, assign) NSUInteger count;

@property (nonatomic, readonly) id __strong *objectBuffer;
@property (nonatomic, readonly) NSUInteger capacity;

@property (nonatomic, strong) id context;

@end


@interface NSArray (RXSequence) <RXSequence>
@end

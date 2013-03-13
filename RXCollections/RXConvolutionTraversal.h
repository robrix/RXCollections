//  RXConvolutionTraversal.h
//  Created by Rob Rix on 2013-03-12.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

typedef id(^RXConvolutionBlock)(NSUInteger count, id const objects[count]);

/**
 id<RXTraversal> RXConvolveWith(id<RXFiniteTraversal> sequences, id(^)(...))
 */

extern id<RXTraversal> RXConvolveWith(id<RXFiniteTraversal> sequences, RXConvolutionBlock block);
extern id (* const RXZipWith)(id<RXFiniteTraversal>, RXConvolutionBlock);

/**
 id<RXTraversal> RXConvolve(id<RXFiniteTraversal> sequences)
 
 Traverses the elements of the sequences in lockstep, producing a tuple for each one.
 
 RXZip is a synonym for this function.
 */
extern id<RXTraversal> RXConvolve(id<RXFiniteTraversal> sequences);
extern id (* const RXZip)(id<RXFiniteTraversal>);


@interface RXConvolutionTraversal : NSObject <RXTraversal>

+(instancetype)traversalWithSequences:(id<RXFiniteTraversal>)sequences block:(RXConvolutionBlock)block;

@property (nonatomic, readonly) id<RXFiniteTraversal> sequences;

@end

//  RXConvolution.h
//  Created by Rob Rix on 2013-03-12.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

typedef id(^RXConvolutionBlock)(NSUInteger count, id const objects[count]);

/**
 id<RXTraversal> RXConvolveWith(id<NSFastEnumeration> sequences, RXConvolutionBlock block)
 
 Traverses the elements of the sequences in lockstep, producing the result of the block (called with the count and an array of the corresponding elements of each sequence) for each one.
 
 RXZipWith is a synonym for this function.
 */
extern id<RXTraversal> RXConvolveWith(id<NSFastEnumeration> sequences, RXConvolutionBlock block);
extern id (* const RXZipWith)(id<NSFastEnumeration>, RXConvolutionBlock);

/**
 id<RXTraversal> RXConvolve(id<NSFastEnumeration> sequences)
 
 Traverses the elements of the sequences in lockstep, producing a tuple for each one.
 
 RXZip is a synonym for this function.
 */
extern id<RXTraversal> RXConvolve(id<NSFastEnumeration> sequences);
extern id (* const RXZip)(id<NSFastEnumeration>);

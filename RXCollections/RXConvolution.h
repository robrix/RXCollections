//  RXConvolution.h
//  Created by Rob Rix on 2013-03-12.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

typedef id(^RXConvolutionBlock)(NSUInteger count, id const objects[count]);
typedef id(*RXConvolutionFunction)(NSUInteger count, id const objects[count]);

/**
 id<RXTraversal> RXConvolveWith(id<NSFastEnumeration> sequences, RXConvolutionBlock block)
 id<RXTraversal> RXConvolveWithF(id<NSFastEnumeration> sequences, RXConvolutionFunction function)
 
 Traverses the elements of the sequences in lockstep, producing the result of the block (called with the count and an array of the corresponding elements of each sequence) for each one.
 
 RXZipWith is a synonym for RXConvolveWith.
 RXZipWithF is a synonym for RXConvolveWithF.
 */
extern id<RXTraversal> RXConvolveWith(id<NSObject, NSFastEnumeration> sequences, RXConvolutionBlock block);
extern id<RXTraversal> RXConvolveWithF(id<NSObject, NSFastEnumeration> sequences, RXConvolutionFunction function);
extern id (* const RXZipWith)(id<NSObject, NSFastEnumeration>, RXConvolutionBlock);
extern id (* const RXZipWithF)(id<NSObject, NSFastEnumeration>, RXConvolutionFunction);

/**
 id<RXTraversal> RXConvolve(id<NSFastEnumeration> sequences)
 
 Traverses the elements of the sequences in lockstep, producing a tuple for each one.
 
 RXZip is a synonym for this function.
 */
extern id<RXTraversal> RXConvolve(id<NSObject, NSFastEnumeration> sequences);
extern id (* const RXZip)(id<NSObject, NSFastEnumeration>);

//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXEnumerator.h>

typedef id(^RXConvolutionBlock)(NSUInteger count, id const objects[count]);

/**
 Traverses the elements of the sequences in lockstep, producing the result of the block (called with the count and an array of the corresponding elements of each sequence) for each one.
 
 \param sequences An enumeration producing the enumerations to be convolved.
 \param block The block to be called with each set of objects.
 \return A traversal producing the results of \c block called with the elements produced by \c sequences in order.
 */
extern id<RXEnumerator> RXConvolveWith(id<NSObject, NSFastEnumeration> sequences, RXConvolutionBlock block);

/**
 An alias for \c RXConvolveWith.
 */
extern id (* const RXZipWith)(id<NSObject, NSFastEnumeration>, RXConvolutionBlock);

/**
 Traverses the elements of the sequences in lockstep, producing a tuple for each one.
 
 \param sequences An enumeration producing the enumerations to be convolved.
 \return A traversal producing tuples of the elements produced by \c sequences in order.
 */
extern id<RXEnumerator> RXConvolve(id<NSObject, NSFastEnumeration> sequences);

/**
 An alias for \c RXConvolve.
 */
extern id (* const RXZip)(id<NSObject, NSFastEnumeration>);

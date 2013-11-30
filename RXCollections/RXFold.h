//  Copyright (c) 2013 Rob Rix. All rights reserved.

@import Foundation;

/**
 A block type used for folding.
 
 \param memo The value produced by the previous iteration. On the first iteration, this will be the initial value.
 \param each The object being folded by this iteration.
 */
typedef id (^RXFoldBlock)(id memo, id each);

/**
 Folds \c enumeration with \c block.
 
 This is a strictly-evaluated fold.
 
 \param enumeration The enumeration to be folded over.
 \param initial The value passed to \c block as its \c memo argument.
 \param block The block to fold with.
 */
extern id RXFold(id<NSFastEnumeration> enumeration, id initial, RXFoldBlock block);


#pragma mark Constructors

/**
 Constructs an array with the elements of the specified traversal. The enumeration's elements must not be nil.
 */
extern NSArray *RXConstructArray(id<NSObject, NSFastEnumeration> enumeration);

/**
 Constructs a set with the elements of the specified enumeration. The enumeration's elements must not be nil.
 */
extern NSSet *RXConstructSet(id<NSFastEnumeration> enumeration);

/**
 Constructs a dictionary with the elements of the specified enumeration. The enumeration's elements must not be nil, and must conform to RXKeyValuePair.
 */
extern NSDictionary *RXConstructDictionary(id<NSFastEnumeration> enumeration);

/**
 Constructs a tuple with the elements of the specified enumeration. The enumeration's elements may be nil.
 */
@class RXTuple;
extern RXTuple *RXConstructTuple(id<NSFastEnumeration> enumeration);

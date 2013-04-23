//  RXFilter.h
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

typedef bool (^RXFilterBlock)(id each);

/**
 RXFilterBlock const RXAcceptFilterBlock
 
 A filter which accepts all objects.
 */
extern RXFilterBlock const RXAcceptFilterBlock;

/**
 RXFilterBlock const RXRejectFilterBlock
 
 A filter which rejects all objects.
 */
extern RXFilterBlock const RXRejectFilterBlock;

/**
 RXFilterBlock const RXAcceptNilFilterBlock
 
 A filter which accepts only nil.
 */
extern RXFilterBlock const RXAcceptNilFilterBlock;

/**
 RXFilterBlock const RXRejectNilFilterBlock
 
 A filter which rejects only nil.
 */
extern RXFilterBlock const RXRejectNilFilterBlock;

/**
 id<RXTraversal> RXFilter(id<NSObject, NSFastEnumeration> enumeration, RXFilterBlock block)
 
 Returns a traversal of the elements of `enumeration` which are matched by `block`.
 */
extern id<RXTraversal> RXFilter(id<NSObject, NSFastEnumeration> enumeration, RXFilterBlock block);

/**
 id RXLinearSearch(id<NSFastEnumeration> collection, RXFilterBlock block)
 
 Returns the first element found in `collection` which is matched by `block`.
 
 RXDetect is a synonym for this function.
 */
extern id RXLinearSearch(id<NSFastEnumeration> collection, RXFilterBlock block);
extern id (* const RXDetect)(id<NSFastEnumeration>, RXFilterBlock);

#pragma mark Function Pointer Support

typedef bool (*RXFilterFunction)(id each);

/**
 RXFilterFunction const RXAcceptFilterFunction
 
 A filter which accepts all objects.
 */
extern RXFilterFunction const RXAcceptFilterFunction;

/**
 RXFilterFunction const RXRejectFilterFunction
 
 A filter which rejects all objects.
 */
extern RXFilterFunction const RXRejectFilterFunction;

/**
 RXFilterFunction const RXAcceptNilFilterFunction
 
 A filter which accepts only nil.
 */
extern RXFilterFunction const RXAcceptNilFilterFunction;

/**
 RXFilterFunction const RXRejectNilFilterFunction
 
 A filter which rejects only nil.
 */
extern RXFilterFunction const RXRejectNilFilterFunction;

/**
 id<RXTraversal> RXFilterF(id<NSObject, NSFastEnumeration> enumeration, RXFilterFunction function)
 
 Returns a traversal of the elements of `enumeration` which are matched by `function`.
 */
extern id<RXTraversal> RXFilterF(id<NSObject, NSFastEnumeration> enumeration, RXFilterFunction function);

/**
 id RXLinearSearch(id<NSFastEnumeration> collection, RXFilterBlock block)
 
 Returns the first element found in `collection` which is matched by `function`.
 
 RXDetect is a synonym for this function.
 */
extern id RXLinearSearchF(id<NSFastEnumeration> collection, RXFilterFunction function);
extern id (* const RXDetectF)(id<NSFastEnumeration>, RXFilterFunction);

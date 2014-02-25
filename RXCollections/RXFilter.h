//  RXFilter.h
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

typedef bool (^RXFilterBlock)(id each, bool *stop);
typedef bool (*RXFilterFunction)(id each, bool *stop);

/**
 A filter which accepts all objects.
 */
extern RXFilterBlock const RXAcceptFilterBlock;

/**
 A filter which rejects all objects.
 */
extern RXFilterBlock const RXRejectFilterBlock;

/**
 A filter which accepts only nil.
 */
extern RXFilterBlock const RXAcceptNilFilterBlock;

/**
 A filter which rejects only nil.
 */
extern RXFilterBlock const RXRejectNilFilterBlock;

/**
 Returns a traversal of the elements of `enumeration` which are matched by `block` or `function`.
 */
extern id<RXTraversal> RXFilter(id<NSObject, NSFastEnumeration> enumeration, RXFilterBlock block);
extern id<RXTraversal> RXFilterF(id<NSObject, NSFastEnumeration> enumeration, RXFilterFunction function);

/**
 Returns the first element found in `collection` which is matched by `block` or `function`.
 
 RXDetect is a synonym for RXLinearSearch.
 RXDetectF is a synonym for RXLinearSearchF.
 */
extern id RXLinearSearch(id<NSFastEnumeration> collection, RXFilterBlock block);
extern id RXLinearSearchF(id<NSFastEnumeration> collection, RXFilterFunction function);
extern id (* const RXDetect)(id<NSFastEnumeration>, RXFilterBlock);
extern id (* const RXDetectF)(id<NSFastEnumeration>, RXFilterFunction);

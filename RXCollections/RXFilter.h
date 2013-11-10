//  RXFilter.h
//  Created by Rob Rix on 2013-02-21.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

/**
 A block type used for filtering.
 */
typedef bool (^RXFilterBlock)(id each, bool *stop);

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
 Returns a traversal of the elements of \c enumeration which are matched by \c block.
 */
extern id<RXTraversal> RXFilter(id<NSObject, NSFastEnumeration> enumeration, RXFilterBlock block);

/**
 Returns the first element found in \c collection which is matched by \c block.
 */
extern id RXLinearSearch(id<NSFastEnumeration> collection, RXFilterBlock block);

/**
 An alias for \c RXLinearSearch.
 */
extern id (* const RXDetect)(id<NSFastEnumeration>, RXFilterBlock);

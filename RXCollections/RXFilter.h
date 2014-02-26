//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXEnumerator.h>

/**
 A block type used for filtering.
 */
typedef bool (^RXFilterBlock)(id each);

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
 Returns an enumerator of the elements of \c enumeration which are matched by \c block.
 */
extern id<RXEnumerator> RXFilter(id<NSObject, NSCopying, NSFastEnumeration> enumeration, RXFilterBlock block);

/**
 Returns the first element found in \c collection which is matched by \c block.
 */
extern id RXLinearSearch(id<NSObject, NSCopying, NSFastEnumeration> collection, RXFilterBlock block);

/**
 An alias for \c RXLinearSearch.
 */
extern id (* const RXDetect)(id<NSObject, NSCopying, NSFastEnumeration>, RXFilterBlock);

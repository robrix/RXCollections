//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTraversal.h>

/**
 A block type used for mapping.
 
 \param each The object being mapped by this iteration.
 \param stop A flag which can be set to stop iteration, analogous to the \c break keyword.
 */
typedef id (^RXMapBlock)(id each, bool *stop);

/**
 Returns its argument.
 */
extern RXMapBlock const RXIdentityMapBlock;

/**
 Returns a traversal which lazily maps the values in \c enumeration using \c block.
 
 It is valid for \c block to return nil.
 
 \param enumeration The enumeration to be mapped over.
 \param block The block to map with.
 */
extern id<RXTraversal> RXMap(id<NSObject, NSFastEnumeration> enumeration, RXMapBlock block);

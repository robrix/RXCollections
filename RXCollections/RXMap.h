//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXEnumerator.h>

/**
 A block type used for mapping.
 
 \param each The object being mapped by this iteration.
 */
typedef id (^RXMapBlock)(id each);

/**
 Returns its argument.
 */
extern RXMapBlock const RXIdentityMapBlock;

/**
 Returns an enumerator which lazily maps the values in \c enumeration using \c block.
 
 It is valid for \c block to return nil.
 
 \param enumeration The enumeration to be mapped over.
 \param block The block to map with.
 */
extern id<RXEnumerator> RXMap(id<NSObject, NSFastEnumeration> enumeration, RXMapBlock block);

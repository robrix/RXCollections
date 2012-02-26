//  RXCollection.h
//  Created by Rob Rix on 11-11-20.
//  Copyright (c) 2011 Monochrome Industries. All rights reserved.

#import <Foundation/Foundation.h>

/*
 
 how to use these:
 
 - the collection parameter can be anything which can use fast enumeration, most notably arrays; sets; dictionaries; enumerators
 
 - mapping calls the block with each element of the collection and makes a new collection (of the receiving class) containing those objects returned by the calls to the block
 - returning a nil value from your mapping block will cause that entry to be omitted from the resulting set; this allows efficient map-and-filter behaviour
 
 - filtering calls the block with each element of the collection, and makes a new collection (of the receiving class) containing those objects for which the block returned YES
 
 - folding with an initial value calls the block with the initial value and the first value; then with the result of that and the second; and so forth until the collection is exhausted; the final value is returned
 - folding without an initial value is the same as providing an initial value of nil
 - it doesn’t make much sense to fold a set or dictionary (since they’re unordered) unless your operation is commutative. e.g. + is commutative, - is not; a + b = b + a, but a - b may not equal b - a
 
 - detecting returns the first element of the collection for which the block returns YES
 - detecting over an unordered collection is defined, but if multiple elements may match the block then which is returned is undefined
 
 */

typedef id (^RXCollectionMapBlock)(id each);
typedef BOOL (^RXCollectionFilterBlock)(id each);
typedef id (^RXCollectionFoldBlock)(id memo, id each); // memo is the initial value on the first invocation, and thereafter the value returned by the previous invocation of the block


@interface NSArray (RXCollection)

+(NSArray *)rx_arrayByMappingCollection:(id<NSFastEnumeration>)collection withBlock:(RXCollectionMapBlock)block;

+(NSArray *)rx_arrayByFilteringCollection:(id<NSFastEnumeration>)collection withBlock:(RXCollectionFilterBlock)block;

@end

@interface NSArray (RXCollectionFold)

-(id)rx_foldInitialValue:(id)initial withBlock:(RXCollectionFoldBlock)block;
-(id)rx_foldWithBlock:(RXCollectionFoldBlock)block;

-(id)rx_detectWithBlock:(RXCollectionFilterBlock)block;

@end


@interface NSSet (RXCollection)

+(NSSet *)rx_setByMappingCollection:(id<NSFastEnumeration>)collection withBlock:(RXCollectionMapBlock)block;

+(NSSet *)rx_setByFilteringCollection:(id<NSFastEnumeration>)collection withBlock:(RXCollectionFilterBlock)block;

@end

@interface NSSet (RXCollectionFold)

-(id)rx_foldInitialValue:(id)initial withBlock:(RXCollectionFoldBlock)block;
-(id)rx_foldWithBlock:(RXCollectionFoldBlock)block;

-(id)rx_detectWithBlock:(RXCollectionFilterBlock)block;

@end


// don’t have a sensible way to get keys for either of these, with the latter being vastly more damning since it doesn’t do object returns either
//@interface NSDictionary (RXCollection)
//
//+(NSDictionary *)rx_dictionaryByMappingCollection:(id<NSFastEnumeration>)collection withBlock:(RXCollectionMapBlock)block;
//
//+(NSDictionary *)rx_dictionaryByFilteringCollection:(id<NSFastEnumeration>)collection withBlock:(RXCollectionFilterBlock)block;
//
//@end

@interface NSDictionary (RXCollectionFold)

-(id)rx_foldInitialValue:(id)initial withBlock:(RXCollectionFoldBlock)block;
-(id)rx_foldWithBlock:(RXCollectionFoldBlock)block;

-(id)rx_detectWithBlock:(RXCollectionFilterBlock)block;

@end

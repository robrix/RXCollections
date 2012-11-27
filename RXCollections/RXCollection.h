//  RXCollection.h
//  Created by Rob Rix on 11-11-20.
//  Copyright (c) 2011 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

/*
 
 how to use these:

 - these can in most cases be called on anything that conforms to NSFastEnumeration
 
 - mapping calls the block with each element of the collection and makes a new collection (of the receiving class) containing those objects returned by the calls to the block
 - returning a nil value from your mapping block will cause that entry to be omitted from the resulting set; this allows efficient map-and-filter behaviour
 
 - filtering calls the block with each element of the collection, and makes a new collection (of the receiving class) containing those objects for which the block returned YES
 
 - folding with an initial value calls the block with the initial value and the first value; then with the result of that and the second; and so forth until the collection is exhausted; the final value is returned
 - folding without an initial value is the same as providing an initial value of nil
 - it may not make much sense to fold a set or dictionary (since they’re unordered) unless your operation is commutative. e.g. + is commutative, - is not; a + b = b + a, but a - b may not equal b - a
 
 - detecting returns the first element of the collection for which the block returns YES
 - detecting over an unordered collection is defined, but if multiple elements may match the block then which is returned is undefined
 
 - mapping sets produces a set. mapping other collections produces an array by default. implement +rx_emptyMutableCollection to return the default collection type that maps will collect into. use the …IntoCollection: variants to append to an existing mutable collection of any type.
 
 */

typedef id (^RXCollectionMapBlock)(id each);
typedef BOOL (^RXCollectionFilterBlock)(id each);
typedef id (^RXCollectionFoldBlock)(id memo, id each); // memo is the initial value on the first invocation, and thereafter the value returned by the previous invocation of the block

extern RXCollectionMapBlock RXCollectionIdentityBlock;

@protocol RXMutableCollection <NSObject>

-(instancetype)rx_append:(id)element;

@end

@protocol RXCollection <NSObject>

+(id<RXMutableCollection>)rx_emptyMutableCollection;

-(id)rx_foldInitialValue:(id)initial block:(RXCollectionFoldBlock)block;
-(id)rx_foldWithBlock:(RXCollectionFoldBlock)block;

-(id)rx_detectWithBlock:(RXCollectionFilterBlock)block;

-(instancetype)rx_mapIntoCollection:(id<RXMutableCollection>)collection block:(RXCollectionMapBlock)block;
-(instancetype)rx_mapWithBlock:(RXCollectionMapBlock)block;

-(instancetype)rx_filterIntoCollection:(id<RXMutableCollection>)collection block:(RXCollectionFilterBlock)block;
-(instancetype)rx_filterWithBlock:(RXCollectionFilterBlock)block;

@end


@interface NSArray (RXCollection) <RXCollection>
@end

@interface NSMutableArray (RXCollection) <RXMutableCollection>
@end


@interface NSSet (RXCollection) <RXCollection>
@end

@interface NSMutableSet (RXCollection) <RXMutableCollection>
@end


@interface NSDictionary (RXCollection) <RXCollection>
@end


@interface NSEnumerator (RXCollection) <RXCollection>
@end

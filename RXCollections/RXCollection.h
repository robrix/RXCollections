//  RXCollection.h
//  Created by Rob Rix on 11-11-20.
//  Copyright (c) 2011 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

#import <RXCollections/RXPair.h>
#import <RXCollections/RXTraversal.h>

#pragma mark Folds

typedef id (^RXFoldBlock)(id memo, id each); // memo is the initial value on the first invocation, and thereafter the value returned by the previous invocation of the block

/**
 id RXFold(id<RXTraversal> collection, id initial, RXFoldBlock block)
 
 Folds a `collection` with `block`, using `initial` as the `memo` argument to block for the first element.
 */
extern id RXFold(id<RXTraversal> collection, id initial, RXFoldBlock block);


#pragma mark Maps

@protocol RXCollection;

typedef id (^RXMapBlock)(id each);

extern RXMapBlock const RXIdentityMapBlock;

/**
 id<RXCollection> RXMap(id<RXCollection> collection, id<RXCollection> destination, RXMapBlock block)
 
 Maps `collection` into `destination` (or, if that’s nil, into a new collection of the same type as `collection`) using `block`. `block` can return nil; nil values will generally be silently dropped.
 */

extern id<RXCollection> RXMap(id<RXCollection> collection, id<RXCollection> destination, RXMapBlock block);

/**
 id<RXTraversal> RXLazyMap(id<RXTraversal> collection, RXMapBlock block)
 
 Returns a traversal which lazily maps the values in `collection` using `block`. `block` can return nil.
 */

extern id<RXTraversal> RXLazyMap(id<RXTraversal> collection, RXMapBlock block);


#pragma mark Filters

typedef bool (^RXFilterBlock)(id each);

extern RXFilterBlock const RXAcceptFilterBlock;
extern RXFilterBlock const RXRejectFilterBlock;

/**
 id<RXCollection> RXFilter(id<RXCollection> collection, id<RXCollection> destination, RXFilterBlock block)
 
 Populates `destination` (or, if that’s nil, a new collection of the same type as `collection`) with the elements of `collection` matched by `block`.
 */

extern id<RXCollection> RXFilter(id<RXCollection> collection, id<RXCollection> destination, RXFilterBlock block);

/**
 id RXDetect(id<RXTraversal> collection, RXFilterBlock block)
 
 Returns the first element found in `collection` which is matched by `block`.
 */

extern id RXDetect(id<RXTraversal> collection, RXFilterBlock block);


#pragma mark Collections

@protocol RXCollection <NSObject, RXTraversal>

/**
 -(id<RXCollection>)rx_emptyCollection
 
 Returns an empty collection of the same type as the receiver.
 */

-(id<RXCollection>)rx_emptyCollection;

/**
 -(instancetype)rx_append:(id)element
 
 Appends element to the receiver and returns the receiver.
 */

-(instancetype)rx_append:(id)element;

@end


#pragma mark Collection types

@interface NSObject (RXCollection) <RXCollection>
@end


@interface NSArray (RXCollection) <RXCollection>
@end


@interface NSSet (RXCollection) <RXCollection>
@end


@interface NSDictionary (RXCollection) <RXCollection>

-(instancetype)rx_append:(id<RXKeyValuePair>)element;

@end


@interface NSEnumerator (RXCollection) <RXCollection>
@end

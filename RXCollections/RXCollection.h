//  RXCollection.h
//  Created by Rob Rix on 11-11-20.
//  Copyright (c) 2011 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

#import <RXCollections/RXPair.h>
#import <RXCollections/RXTraversal.h>

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

@interface NSArray (RXCollection) <RXCollection>
@end


@interface NSSet (RXCollection) <RXCollection>
@end


@interface NSDictionary (RXCollection) <RXCollection>

-(instancetype)rx_append:(id<RXKeyValuePair>)element;

@end


@interface NSEnumerator (RXCollection) <RXCollection>
@end

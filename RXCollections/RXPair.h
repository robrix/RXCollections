//  RXPair.h
//  Created by Rob Rix on 2013-01-12.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <RXCollections/RXTuple.h>
#import <RXCollections/RXEquating.h>

@protocol RXPair <NSObject>

@property (nonatomic, strong, readonly) id left;
@property (nonatomic, strong, readonly) id right;

@end

@interface RXTuple (RXPair) <RXPair>

+(instancetype)tupleWithLeft:(id)left right:(id)right;

@end


@protocol RXKeyValuePair <NSObject>

@property (nonatomic, copy, readonly) id<NSCopying> key;
@property (nonatomic, strong, readonly) id value;

@end

@interface RXTuple (RXKeyValuePair) <RXKeyValuePair>

+(instancetype)tupleWithKey:(id<NSCopying>)key value:(id)value;

@end


@protocol RXLinkedListNode <NSObject, RXEquating>

@property (nonatomic, strong, readonly) id first;
@property (nonatomic, strong, readonly) id<RXLinkedListNode> rest;

@end

@interface RXTuple (RXLinkedListNode) <RXLinkedListNode>

+(instancetype)tupleWithFirst:(id)first rest:(id<RXLinkedListNode>)rest;

@end

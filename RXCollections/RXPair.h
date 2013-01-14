//  RXPair.h
//  Created by Rob Rix on 2013-01-12.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@interface RXPair : NSObject <NSCopying>

+(instancetype)pairWithLeft:(id)left right:(id)right;
-(instancetype)initWithLeft:(id)left right:(id)right;

@property (nonatomic, strong, readonly) id left;
@property (nonatomic, strong, readonly) id right;

@property (nonatomic, copy, readonly) NSArray *elements;

-(bool)isEqualToPair:(RXPair *)pair;

@end


@protocol RXKeyValuePair <NSObject>

@property (nonatomic, copy, readonly) id<NSCopying> key;
@property (nonatomic, strong, readonly) id value;

@end

@interface RXPair (RXKeyValuePair) <RXKeyValuePair>

+(instancetype)pairWithKey:(id<NSCopying>)key value:(id)value;

@end


@protocol RXLinkedListNode <NSObject>

@property (nonatomic, strong, readonly) id first;
@property (nonatomic, strong, readonly) id rest;

@end

@interface RXPair (RXLinkedListNode) <RXLinkedListNode>

+(instancetype)pairWithFirst:(id)first rest:(id)rest;

@end

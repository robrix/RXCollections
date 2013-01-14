//  RXPair.h
//  Created by Rob Rix on 2013-01-12.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@interface RXPair : NSObject

+(instancetype)pairWithLeft:(id)left right:(id)right;

@property (nonatomic, strong) id left;
@property (nonatomic, strong) id right;

@end


@protocol RXDictionaryPair <NSObject>

@property (nonatomic, copy, readonly) id<NSCopying> key;
@property (nonatomic, strong, readonly) id value;

@end

@protocol RXMutableDictionaryPair <RXDictionaryPair>

@property (nonatomic, copy) id<NSCopying> key;
@property (nonatomic, strong) id value;

@end

@interface RXPair (RXPairNSDictionaryConvenience) <RXMutableDictionaryPair>

+(instancetype)pairWithKey:(id<NSCopying>)key value:(id)value;

@end

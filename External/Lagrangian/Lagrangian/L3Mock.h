//  L3Mock.h
//  Created by Rob Rix on 2013-05-30.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import <Lagrangian/RXFold.h>

@protocol L3Mock;

@interface L3Mock : NSObject

+(id)mockNamed:(NSString *)name initializer:(void(^)(id<L3Mock> mock))initializer;

@end

@protocol L3Mock <NSObject>

-(void)addMethodWithSelector:(SEL)selector types:(const char *)types block:(id)block;

@end

#define L3TypeSignatureEncode(_, type) @encode(type)
#define L3TypeSignature(...) rx_fold(L3TypeSignatureEncode, _, __VA_ARGS__)
const char *L3ConstructTypeSignature(char type[], ...);

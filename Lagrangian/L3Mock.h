#ifndef L3_MOCK_H
#define L3_MOCK_H

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import <RXPreprocessing/fold.h>

@protocol L3MockBuilder;

@interface L3Mock : NSObject

+(instancetype)mockNamed:(NSString *)name initializer:(void(^)(id<L3MockBuilder> mock))initializer;

@end

@protocol L3MockBuilder <NSObject>

-(void)addMethodWithSelector:(SEL)selector types:(const char *)types block:(id)block;

@end

#define L3TypeSignatureEncode(_, type) @encode(type)
#define L3TypeSignature(...) rx_fold(L3TypeSignatureEncode, _, __VA_ARGS__)
const char *L3ConstructTypeSignature(char type[], ...);

#endif // L3_MOCK_H

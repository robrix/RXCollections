#ifndef L3_MOCK_H
#define L3_MOCK_H

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import <RXPreprocessing/fold.h>

@protocol L3MockBuilder;
typedef void(^L3MockInitializer)(id<L3MockBuilder> mock);

@interface L3Mock : NSObject

+(id)mockNamed:(NSString *)name initializer:(L3MockInitializer)initializer;

@end

@protocol L3MockBuilder <NSObject>

/**
 Add a method for a given selector implemented by a given block.
 
 The types are inferred from the types of the block.
 */
-(void)addMethodWithSelector:(SEL)selector block:(id)block;
-(void)addMethodWithSelector:(SEL)selector types:(const char *)types block:(id)block;
-(void)addProtocol:(Protocol *)protocol;

@end

#define L3TypeSignatureEncode(_, type) @encode(type)
#define L3TypeSignature(...) rx_fold(L3TypeSignatureEncode, _, __VA_ARGS__)
const char *L3ConstructTypeSignature(char type[], ...);

#endif // L3_MOCK_H

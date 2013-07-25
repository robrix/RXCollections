#ifndef L3_EXPECT_H
#define L3_EXPECT_H

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import <Lagrangian/L3Defines.h>


#pragma mark Expectations

#define l3_expect(...) \
	L3Expect(test, __COUNTER__, L3Box(__VA_ARGS__))


@interface L3Expectation : NSObject

@property (nonatomic, readonly) L3Expectation *to;

@property (nonatomic, readonly) L3Expectation *(^equal)(id object);

@property (nonatomic, readonly) id subject;

@end


@class L3Test;
L3_EXTERN L3Expectation *L3Expect(L3Test *test, int identifier, id subject);


#pragma mark Boxing

L3_OVERLOADABLE id L3Box(id x) { return x; }

L3_OVERLOADABLE id L3Box(uint64_t v) { return @(v); }
L3_OVERLOADABLE id L3Box(uint32_t v) { return @(v); }
L3_OVERLOADABLE id L3Box(uint16_t v) { return @(v); }
L3_OVERLOADABLE id L3Box(uint8_t v) { return @(v); }
L3_OVERLOADABLE id L3Box(int64_t v) { return @(v); }
L3_OVERLOADABLE id L3Box(int32_t v) { return @(v); }
L3_OVERLOADABLE id L3Box(int16_t v) { return @(v); }
L3_OVERLOADABLE id L3Box(int8_t v) { return @(v); }
L3_OVERLOADABLE id L3Box(unsigned long v) { return @(v); }
L3_OVERLOADABLE id L3Box(signed long v) { return @(v); }
L3_OVERLOADABLE id L3Box(double v) { return @(v); }
L3_OVERLOADABLE id L3Box(float v) { return @(v); }
L3_OVERLOADABLE id L3Box(bool v) { return @(v); }
L3_OVERLOADABLE id L3Box(char *v) { return @(v); }

#endif // L3_EXPECT_H

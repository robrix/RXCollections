#ifndef L3_EXPECT_H
#define L3_EXPECT_H

#import <Foundation/Foundation.h>
#import <Lagrangian/L3Defines.h>
#import <Lagrangian/L3SourceReference.h>


#pragma mark Expectations

#define l3_expect(...) \
	L3Expect(self, l3_source_reference(__VA_ARGS__))


@protocol L3Expectation <NSObject>

@property (readonly) id<L3SourceReference> subjectReference;

@property (readonly) id<L3Expectation> to;
@property (readonly) id<L3Expectation> not;

@property (readonly) bool (^equal)(id object);

@end


@protocol L3TestResult <NSObject>

@property (readonly) id<L3SourceReference> subjectReference;

@property (readonly) NSString *hypothesisString;
@property (readonly) NSString *observationString;

@property (readonly) bool wasMet;
@property (readonly) NSException *exception;

@end


typedef void(^L3TestExpectationBlock)(id<L3Expectation> expectation, id<L3TestResult> result);


@class L3Test;
L3_EXTERN id<L3Expectation> L3Expect(L3Test *test, id<L3SourceReference> subjectReference);
L3_EXTERN id<L3TestResult> L3TestResultCreateWithException(NSException *exception);

#endif // L3_EXPECT_H

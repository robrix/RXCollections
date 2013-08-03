#ifndef L3_EXPECT_H
#define L3_EXPECT_H

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import <Lagrangian/L3Defines.h>
#import <Lagrangian/L3SourceReference.h>


#pragma mark Expectations

#define l3_expect(...) \
	L3Expect(test, withExpectations, l3_source_reference(__VA_ARGS__))


@protocol L3Expectation;

@protocol L3Predicate <NSObject>

@property (nonatomic, weak, readonly) id<L3Expectation> expectation;
@property (nonatomic, readonly) NSPredicate *predicate;

-(bool)testWithSubject:(id)subject;

@property (nonatomic, readonly) NSString *imperativePhrase;

@end


@protocol L3Expectation <NSObject>

@property (nonatomic, readonly) id<L3SourceReference> subjectReference;
@property (nonatomic, readonly) id<L3Predicate> nextPredicate;

@property (nonatomic, readonly) id<L3Expectation> to;
//@property (nonatomic, readonly) id<L3Expectation> notTo;

@property (nonatomic, readonly) bool (^equal)(id object);

-(bool)test;

@property (nonatomic, readonly) NSException *exception;

@property (nonatomic, readonly) NSString *assertivePhrase;
@property (nonatomic, readonly) NSString *indicativePhrase;

@end


@class L3Test;
L3_EXTERN id<L3Expectation> L3Expect(L3Test *test, void(^callback)(id<L3Expectation> expectation, bool wasMet), id<L3SourceReference> subjectReference);

#endif // L3_EXPECT_H

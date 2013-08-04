#ifndef L3_TEST_H
#define L3_TEST_H

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import <Lagrangian/L3Defines.h>
#import <Lagrangian/L3Expectation.h>
#import <Lagrangian/L3SourceReference.h>

#import <RXPreprocessing/concat.h>


#pragma mark API

#if defined(L3_INCLUDE_TESTS)

#define l3_test(...) \
	_l3_test(__COUNTER__, __VA_ARGS__)

#define _l3_test(uid, ...) \
	L3_CONSTRUCTOR void rx_concat(L3Test, uid)(void) { \
		L3Test *suite = [L3Test suiteForFile:@(__FILE__)]; \
		id<L3SourceReference> reference = L3SourceReferenceCreate(@(__COUNTER__), @(__FILE__), __LINE__, nil, nil); \
		__block L3Test *test = [[L3Test alloc] initWithSourceReference:reference block:^(L3TestExpectationBlock withExpectations) { (__VA_ARGS__)(); }]; \
		[suite addChild:test]; \
	}

//#define l3_state(declaration, ...) \
//	declaration

#define l3_setup(symbol, ...) \
	L3TestBlock symbol = __VA_ARGS__

#define l3_step(symbol, ...) \
	L3TestBlock symbol = __VA_ARGS__

#else // L3_INCLUDE_TESTS

#define l3_test(...)

//#define l3_state(...)

#define l3_setup(...)

#define l3_step(...)

#endif // L3_INCLUDE_TESTS


typedef void(^L3TestExpectationBlock)(id<L3Expectation> expectation, bool wasMet);
typedef void(^L3TestBlock)(L3TestExpectationBlock withExpectations);
typedef void(^L3TestBodyBlock)(void);

enum {
	L3AssertionFailedError
};

extern NSString * const L3ErrorDomain;

extern NSString * const L3TestErrorKey;
extern NSString * const L3ExpectationErrorKey;


@protocol L3TestVisitor;

@interface L3Test : NSObject

+(instancetype)suiteForFile:(NSString *)file;

-(instancetype)initWithSourceReference:(id<L3SourceReference>)sourceReference block:(L3TestBlock)block;

@property (nonatomic, readonly) id<L3SourceReference> sourceReference;

//@property (nonatomic, readonly) NSArray *steps;
//-(void)addStep:(L3TestBlock)block;

@property (nonatomic, readonly) NSArray *expectations;
-(void)addExpectation:(id<L3Expectation>)expectation;

@property (nonatomic, readonly) NSArray *children;
-(void)addChild:(L3Test *)test;

//-(void)runSteps;

-(void)run:(L3TestExpectationBlock)callback;

-(id)acceptVisitor:(id<L3TestVisitor>)visitor parents:(NSArray *)parents context:(id)context;

@end

@protocol L3TestDelegate <NSObject>

-(void)test:(L3Test *)test expectation:(id<L3Expectation>)expectation;

@end


@protocol L3TestVisitor <NSObject>

-(id)visitTest:(L3Test *)test parents:(NSArray *)parents lazyChildren:(NSMutableArray *)lazyChildren context:(id)context;

@end

#endif // L3_TEST_H

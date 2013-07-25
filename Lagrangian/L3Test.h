#ifndef L3_TEST_H
#define L3_TEST_H

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import <Lagrangian/L3Defines.h>


#pragma mark API

#if L3_INCLUDE_TESTS

/**
 Declares a test case.
 
 Blocks passed to this macro will have several variables available to them in the surrounding scope when they are created:
 
 \c test The test case.
 \c given
 \c when
 \c expect
 */
#define l3_test(...) \
	_l3_test(__COUNTER__, __VA_ARGS__)

#define _l3_test(uid, ...) \
	_Pragma("clang diagnostic push") \
	_Pragma("clang diagnostic ignored \"-Wused-but-marked-unused\"") \
	L3_CONSTRUCTOR void L3_PASTE(L3Test, uid)(void) { \
		L3Test *test = [L3Test new]; \
		L3ExpectBlock expect = L3ExpectBlockForTest(test); \
		L3GivenBlock given = L3GivenBlockForTest(test); \
		L3WhenBlock when = L3WhenBlockForTest(test); \
		_Pragma("unused (expect, given, when)") \
		L3TestInitialize(test, __VA_ARGS__); \
	} \
	_Pragma("clang diagnostic pop")

#define l3_state(declaration, ...) \
	declaration;

#define l3_setup(symbol, ...) \
	L3TestBlock symbol = __VA_ARGS__

#define l3_step(symbol, ...) \
	L3TestBlock symbol = __VA_ARGS__


#else // L3_INCLUDE_TESTS

#define l3_test(...)

#define l3_state(...)

#define l3_setup(...)

#define l3_step(...)

#endif // L3_INCLUDE_TESTS


typedef void(^L3TestBlock)(void);
typedef void(^L3GivenBlock)(L3TestBlock block);
typedef void(^L3WhenBlock)(L3TestBlock block);
typedef void(^L3ExpectBlock)(id subject);


@protocol L3TestVisitor;


@interface L3Test : NSObject

@property (nonatomic, copy) L3TestBlock block;

@property (nonatomic, readonly) NSArray *preconditions;
-(void)addPrecondition:(L3TestBlock)block;

@property (nonatomic, readonly) NSArray *steps;
-(void)addStep:(L3TestBlock)block;

@property (nonatomic, readonly) NSArray *expectations;
-(void)addExpectation:(id)expectation;

@property (nonatomic, readonly) NSArray *children;
-(void)addChild:(L3Test *)test;

-(id)acceptVisitor:(id<L3TestVisitor>)visitor context:(id)context;

@end


@protocol L3TestVisitor <NSObject>

-(id)visitTest:(L3Test *)test children:(NSMutableArray *)children context:(id)context;

@end


L3_EXTERN L3WhenBlock L3WhenBlockForTest(L3Test *test);
L3_EXTERN L3GivenBlock L3GivenBlockForTest(L3Test *test);
L3_EXTERN L3ExpectBlock L3ExpectBlockForTest(L3Test *test);


L3_OVERLOADABLE void L3TestInitialize(L3Test *test, L3TestBlock block);
L3_OVERLOADABLE void L3TestInitialize(L3Test *test, NSString *todo);

L3_OVERLOADABLE void L3TestInitialize(L3Test *test, L3TestBlock block) {
	block();
}

L3_OVERLOADABLE void L3TestInitialize(L3Test *test, NSString *todo) {
	
}

#endif // L3_TEST_H

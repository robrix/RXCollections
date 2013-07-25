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

#define l3_test(...) \
	_l3_test(__COUNTER__, __VA_ARGS__)

#define _l3_test(uid, ...) \
	L3_CONSTRUCTOR void L3_PASTE(L3Test, uid)(void) { \
		__block L3Test *test = [[L3Test alloc] initWithFile:@(__FILE__) line:__LINE__ block:__VA_ARGS__]; \
		"add test to the runner and immediately prior registered test (i.e. its suite)"; \
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


typedef void(^L3TestBlock)(void);


@class L3Expectation;
@protocol L3TestVisitor;


@interface L3Test : NSObject

-(instancetype)initWithFile:(NSString *)file line:(NSUInteger)line block:(L3TestBlock)block;

@property (nonatomic, readonly) NSString *file;
@property (nonatomic, readonly) NSUInteger line;

@property (nonatomic, readonly) NSArray *steps;
-(void)addStep:(L3TestBlock)block;

@property (nonatomic, readonly) NSArray *expectations;
-(void)addExpectation:(L3Expectation *)expectation;

@property (nonatomic, readonly) NSArray *children;
-(void)addChild:(L3Test *)test;

-(void)runSteps;

-(id)acceptVisitor:(id<L3TestVisitor>)visitor parents:(NSArray *)parents context:(id)context;

@end


@protocol L3TestVisitor <NSObject>

-(id)visitTest:(L3Test *)test parents:(NSArray *)parents children:(NSMutableArray *)children context:(id)context;

@end

#endif // L3_TEST_H

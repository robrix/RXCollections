#ifndef L3_TEST_H
#define L3_TEST_H

#if __has_feature(modules)
@import Foundation;
@import Darwin.POSIX.dlfcn;
#else
#import <Foundation/Foundation.h>
#import <dlfcn.h>
#endif

#import <Lagrangian/L3Defines.h>
#import <Lagrangian/L3Expectation.h>
#import <Lagrangian/L3SourceReference.h>

#import <RXPreprocessing/concat.h>


#pragma mark API

#if defined(L3_INCLUDE_TESTS)

#define l3_test(...) \
	_l3_test(__FILE__, __LINE__, __COUNTER__, __VA_ARGS__)

#define _l3_test(file, line, uid, ...) \
	L3_CONSTRUCTOR void rx_concat(L3Test, uid)(void) { \
		L3Test *suite = [L3Test suiteForFile:@(file) inImageForAddress:rx_concat(L3Test, uid)]; \
		__block L3Test *self = L3TestDefine(@(file), line, __VA_ARGS__); \
		[suite addChild:self]; \
	}

#else // defined(L3_INCLUDE_TESTS)

#define l3_test(...)

#endif // defined(L3_INCLUDE_TESTS)


typedef void(^L3TestBlock)(void);

enum {
	L3AssertionFailedError
};

extern NSString * const L3ErrorDomain;

extern NSString * const L3TestErrorKey;
extern NSString * const L3ExpectationErrorKey;


@protocol L3TestVisitor;

@interface L3Test : NSObject

+(NSDictionary *)registeredSuites;

+(instancetype)registeredSuiteForFile:(NSString *)file;
+(instancetype)suiteForFile:(NSString *)file inImageForAddress:(void(*)(void))address;

+(instancetype)testWithSourceReference:(id<L3SourceReference>)sourceReference block:(L3TestBlock)block;
-(instancetype)initWithSourceReference:(id<L3SourceReference>)sourceReference block:(L3TestBlock)block;

@property (nonatomic, readonly) id<L3SourceReference> sourceReference;

@property (nonatomic, readonly) NSArray *expectations;
-(void)addExpectation:(id<L3Expectation>)expectation;

@property (nonatomic, readonly) NSArray *children;
-(void)addChild:(L3Test *)test;

-(void)run:(L3TestExpectationBlock)callback;

-(id)acceptVisitor:(id<L3TestVisitor>)visitor parents:(NSArray *)parents context:(id)context;

-(void)expectation:(id<L3Expectation>)expectation producedResult:(id<L3TestResult>)result;

@end

@protocol L3TestDelegate <NSObject>

-(void)test:(L3Test *)test expectation:(id<L3Expectation>)expectation;

@end


@protocol L3TestVisitor <NSObject>

-(id)visitTest:(L3Test *)test parents:(NSArray *)parents lazyChildren:(NSMutableArray *)lazyChildren context:(id)context;

@end

typedef id (*L3TestFunctionSubject)(id, ...);
extern L3Test *L3TestDefineWithFunction(NSString *file, NSUInteger line, L3TestFunctionSubject subject, L3TestBlock block);

L3_OVERLOADABLE L3Test *L3TestDefine(NSString *file, NSUInteger line, SEL subject, L3TestBlock block) {
	return [L3Test testWithSourceReference:L3SourceReferenceCreate(nil, file, line, nil, NSStringFromSelector(subject)) block:block];
}

L3_OVERLOADABLE L3Test *L3TestDefine(NSString *file, NSUInteger line, const char *subject, L3TestBlock block) {
	return [L3Test testWithSourceReference:L3SourceReferenceCreate(nil, file, line, nil, @(subject)) block:block];
}

L3_OVERLOADABLE L3Test *L3TestDefine(NSString *file, NSUInteger line, NSString *(*subject)(NSString *, NSDictionary *), L3TestBlock block) {
	return L3TestDefineWithFunction(file, line, (L3TestFunctionSubject)subject, block);
}

#endif // L3_TEST_H

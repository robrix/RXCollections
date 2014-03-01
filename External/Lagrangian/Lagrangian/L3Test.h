#ifndef L3_TEST_H
#define L3_TEST_H

#import <Foundation/Foundation.h>
#import <Lagrangian/L3Defines.h>
#import <Lagrangian/L3Expectation.h>
#import <Lagrangian/L3SourceReference.h>


#pragma mark API

#define l3_test(...) \
	_l3_test_construct(__COUNTER__, __VA_ARGS__)

#if defined(L3_INCLUDE_TESTS)

#define _l3_test_construct(uid, ...) \
	L3_INLINE void _l3_test_function_name(uid) (L3Test *suite, L3Test *self); \
	L3_CONSTRUCTOR void _l3_test_constructor_name(uid) (void) { \
		L3Test *suite = [L3Test suiteForFile:@__FILE__ inImageForAddress:_l3_test_constructor_name(uid)]; \
		__block L3Test *test = L3TestDefine(@__FILE__, __LINE__, __VA_ARGS__, ^{ _l3_test_function_name(uid)(suite, test); }); \
		test.statePrototype = suite.statePrototype; \
		[suite addChild:test]; \
	} \
	L3_INLINE void _l3_test_function_name(uid) (L3Test *suite, L3Test *self)

#define _l3_test_constructor_name(uid) \
	metamacro_concat(L3TestConstructor, uid)

#define _l3_test_function_name(uid) \
	metamacro_concat(L3TestFunction, uid)

#else // defined(L3_INCLUDE_TESTS)

#define _l3_test_construct(uid, ...) \
	L3_UNUSABLE void metamacro_concat(metamacro_concat(L3, uid), UnusableTestFunction) (L3Test *suite, L3Test *self)

#endif // defined(L3_INCLUDE_TESTS)


typedef void(^L3TestBlock)(void);

enum {
	L3AssertionFailedError
};

L3_EXTERN NSString * const L3ErrorDomain;

L3_EXTERN NSString * const L3TestErrorKey;
L3_EXTERN NSString * const L3ExpectationErrorKey;


@protocol L3TestVisitor;
@class L3TestStatePrototype;

@interface L3Test : NSObject

+(NSDictionary *)registeredSuites;

+(instancetype)registeredSuiteForFile:(NSString *)file;
+(instancetype)suiteForFile:(NSString *)file inImageForAddress:(void(*)(void))address;

+(instancetype)testWithSourceReference:(id<L3SourceReference>)sourceReference block:(L3TestBlock)block;
-(instancetype)initWithSourceReference:(id<L3SourceReference>)sourceReference block:(L3TestBlock)block;

@property (readonly) id<L3SourceReference> sourceReference;

@property (readonly) NSArray *expectations;
-(void)addExpectation:(id<L3Expectation>)expectation;

@property (readonly) NSArray *children;
-(void)addChild:(L3Test *)test;

@property L3TestStatePrototype *statePrototype;

-(void)setUp;
-(void)tearDown;
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

typedef void (*L3FunctionTestSubject)(void *, ...);
L3_EXTERN NSString *L3TestSymbolForFunction(L3FunctionTestSubject subject);
typedef id (^L3BlockTestSubject)();
L3_EXTERN L3FunctionTestSubject L3TestFunctionForBlock(L3BlockTestSubject subject);

L3_OVERLOADABLE L3Test *L3TestDefine(NSString *file, NSUInteger line, SEL subject, L3TestBlock block) {
	return [L3Test testWithSourceReference:L3SourceReferenceCreate(nil, file, line, nil, NSStringFromSelector(subject)) block:block];
}

L3_OVERLOADABLE L3Test *L3TestDefine(NSString *file, NSUInteger line, const char *subject, L3TestBlock block) {
	return [L3Test testWithSourceReference:L3SourceReferenceCreate(nil, file, line, nil, @(subject)) block:block];
}

L3_OVERLOADABLE L3Test *L3TestDefine(NSString *file, NSUInteger line, NSString *(*subject)(NSString *, NSDictionary *), L3TestBlock block) {
	return [L3Test testWithSourceReference:L3SourceReferenceCreate(nil, file, line, nil, L3TestSymbolForFunction((L3FunctionTestSubject)subject)) block:block];
}

L3_OVERLOADABLE L3Test *L3TestDefine(NSString *file, NSUInteger line, id (^subject)(id), L3TestBlock block) {
	return [L3Test testWithSourceReference:L3SourceReferenceCreate(nil, file, line, nil, L3TestSymbolForFunction((L3FunctionTestSubject)L3TestFunctionForBlock((L3BlockTestSubject)subject))) block:block];
}

/**
 Registers the type of the passed function as allowable as a test subject (i.e. the first parameter to \c l3_test).
 
 Note that clang C function overloading seems to require that the address of the function be taken explicitly, e.g. `l3_test(&sinf, ^{})`.
 
 \param functionSubject The function whose type should be valid as a test subject.
 */
#define l3_addTestSubjectTypeWithFunction(functionSubject) \
	L3_OVERLOADABLE L3Test *L3TestDefine(NSString *file, NSUInteger line, __typeof__(functionSubject) subject, L3TestBlock block) { \
		return [L3Test testWithSourceReference:L3SourceReferenceCreate(nil, file, line, nil, L3TestSymbolForFunction((L3FunctionTestSubject)subject)) block:block]; \
	}

/**
 Registers the type of the passed block as allowable as a test subject (i.e. the first parameter to \c l3_test).
 
 \param blockSubject The block whose type should be valid as a test subject.
 */
#define l3_addTestSubjectTypeWithBlock(blockSubject) \
	L3_OVERLOADABLE L3Test *L3TestDefine(NSString *file, NSUInteger line, __typeof__(blockSubject) subject, L3TestBlock block) { \
		return [L3Test testWithSourceReference:L3SourceReferenceCreate(nil, file, line, nil, L3TestSymbolForFunction((L3FunctionTestSubject)L3TestFunctionForBlock((L3BlockTestSubject)subject))) block:block]; \
	}

#endif // L3_TEST_H

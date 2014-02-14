#ifndef L3_TEST_STATE_H
#define L3_TEST_STATE_H

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import <Lagrangian/L3Defines.h>

#import <RXPreprocessing/concat.h>
#import <RXPreprocessing/fold.h>


#pragma mark API

#if defined(L3_INCLUDE_TESTS)

#define l3_setup(...) \
	_l3_setup(__COUNTER__, __VA_ARGS__)

#define _l3_setup(uid, declarations, ...) \
	@protocol _l3_state_protocol_name(uid) <NSObject> \
	_l3_declarations_as_properties declarations \
	@end \
	@interface L3Test (_l3_state_protocol_name(uid)) \
	@property (nonatomic, readonly) L3TestState<_l3_state_protocol_name(uid)> *state; \
	@end \
	L3_CONSTRUCTOR void rx_concat(L3TestStateConstructor, uid)(void) { \
		L3Test *suite = [L3Test suiteForFile:@(__FILE__) inImageForAddress:rx_concat(L3TestStateConstructor, uid)]; \
		suite.statePrototype = (id)L3TestStatePrototypeDefine(@protocol(_l3_state_protocol_name(uid)), ^(L3Test *self){ (__VA_ARGS__)(); }); \
	}

#define _l3_declaration_as_property(memo, each) \
	@property (nonatomic) each; \
	memo

#define _l3_declarations_as_properties(...) \
	rx_fold(_l3_declaration_as_property, , __VA_ARGS__)

#define _l3_state_protocol_name(uid) \
	rx_concat(L3TestStateProtocol_line_, rx_concat(__LINE__, rx_concat(_uid_, uid)))

#else // defined(L3_INCLUDE_TESTS)

#define l3_setup(...)

#endif // defined(L3_INCLUDE_TESTS)


@class L3Test;
typedef void(^L3TestStateBlock)(L3Test *self);

@class L3TestState;
@interface L3TestStatePrototype : NSObject

+(instancetype)statePrototypeWithProtocol:(Protocol *)stateProtocol setUpBlock:(L3TestStateBlock)setUpBlock;

-(L3TestState *)createState;

@end

@interface L3TestState : NSObject

@property (nonatomic, readonly) Protocol *stateProtocol;

@property (nonatomic, readonly) NSMutableDictionary *properties;

-(void)setUpWithTest:(L3Test *)test;
@property (nonatomic, readonly) L3TestStateBlock setUpBlock;

@end

L3_OVERLOADABLE L3TestStatePrototype *L3TestStatePrototypeDefine(Protocol *stateProtocol, L3TestStateBlock setUpBlock) {
	return [L3TestStatePrototype statePrototypeWithProtocol:stateProtocol setUpBlock:setUpBlock];
}

#endif // L3_TEST_STATE_H

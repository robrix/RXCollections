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

#define l3_state(...) \
	_l3_state(__COUNTER__, __VA_ARGS__)

#define _l3_state(uid, declarations, ...) \
	@protocol _l3_state_protocol_name(uid) <NSObject> \
	_l3_declarations_as_properties declarations \
	@end \
	__attribute__((unused)) static const L3TestState<_l3_state_protocol_name(uid)> *L3TestStateVariable = nil; \
	L3_CONSTRUCTOR void rx_concat(L3TestStateConstructor, uid)(void) { \
		L3TestStateDefine(@protocol(_l3_state_protocol_name(uid)), __VA_ARGS__); \
	}

#define _l3_declaration_as_property(memo, each) \
	@property (nonatomic) each; \
	memo

#define _l3_declarations_as_properties(...) \
	rx_fold(_l3_declaration_as_property, , __VA_ARGS__)

#define _l3_state_protocol_name(uid) \
	rx_concat(L3TestStateProtocol_line_, rx_concat(__LINE__, rx_concat(_uid_, uid)))

#else // defined(L3_INCLUDE_TESTS)

#define l3_state(...)

#endif // defined(L3_INCLUDE_TESTS)


@interface L3TestState : NSObject

+(instancetype)stateWithProtocol:(Protocol *)stateProtocol;

@property (nonatomic, readonly) Protocol *stateProtocol;

@property (nonatomic, readonly) NSMutableDictionary *properties;

@end

L3_OVERLOADABLE L3TestState *L3TestStateDefine(Protocol *stateProtocol, void(^setUp)()) {
	return nil;
}

#endif // L3_TEST_STATE_H

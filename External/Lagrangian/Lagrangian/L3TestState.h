#ifndef L3_TEST_STATE_H
#define L3_TEST_STATE_H

#import <Foundation/Foundation.h>
#import <Lagrangian/L3Defines.h>


#pragma mark API

#define l3_setup(name, declarations) \
	_l3_state_protocol_definition(name, declarations) \
	_l3_test_state_property_declaration(name) \
	_l3_state_construct(name)


#define _l3_state_protocol_definition(name, declarations) \
	@protocol _l3_state_protocol_name(name) <NSObject> \
	_l3_declarations_as_properties declarations \
	@end

#define _l3_test_state_property_declaration(name) \
	@interface L3Test (_l3_state_protocol_name(name)) \
	@property (readonly) L3TestState<_l3_state_protocol_name(name)> *state; \
	@end

#define _l3_declaration_as_property(_, each) \
	@property each; \

#define _l3_declarations_as_properties(...) \
	metamacro_foreach(_l3_declaration_as_property, , __VA_ARGS__)

#define _l3_state_protocol_name(name) \
	metamacro_concat(metamacro_concat(L3, name), State)


#if defined(L3_INCLUDE_TESTS)

#define _l3_state_construct(name) \
	L3_INLINE void _l3_setup_function_name(name) (L3Test *self); \
	L3_CONSTRUCTOR void _l3_state_constructor_name(name) (void) { \
		L3Test *suite = [L3Test suiteForFile:@(__FILE__) inImageForAddress:_l3_state_constructor_name(name)]; \
		suite.statePrototype = [L3TestStatePrototype statePrototypeWithProtocol:@protocol(_l3_state_protocol_name(name)) setupFunction:_l3_setup_function_name(name)]; \
	} \
	\
	L3_INLINE void _l3_setup_function_name(name) (L3Test *self)

#define _l3_state_constructor_name(name) \
	metamacro_concat(_l3_state_protocol_name(name), Constructor)

#define _l3_setup_function_name(name) \
	metamacro_concat(_l3_state_protocol_name(name), Setup)

#else // defined(L3_INCLUDE_TESTS)

#define _l3_state_construct(name) \
	L3_UNUSABLE void metamacro_concat(metamacro_concat(L3, name), UnusableSetupFunction) (L3Test *self)

#endif // defined(L3_INCLUDE_TESTS)


@class L3Test;
typedef void (*L3TestSetupFunction)(L3Test *self);

@class L3TestState;
@interface L3TestStatePrototype : NSObject

+(instancetype)statePrototypeWithProtocol:(Protocol *)stateProtocol setupFunction:(L3TestSetupFunction)setupFunction;

-(L3TestState *)createState;

@end

@interface L3TestState : NSObject

@property (readonly) Protocol *stateProtocol;

@property (readonly) NSMutableDictionary *properties;

-(void)setUpWithTest:(L3Test *)test;
@property (readonly) L3TestSetupFunction setupFunction;

@end

L3_OVERLOADABLE L3TestStatePrototype *L3TestStatePrototypeDefine(Protocol *stateProtocol, L3TestSetupFunction setupFunction) {
	return [L3TestStatePrototype statePrototypeWithProtocol:stateProtocol setupFunction:setupFunction];
}

#endif // L3_TEST_STATE_H

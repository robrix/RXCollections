#ifndef L3_DEFINES_H
#define L3_DEFINES_H

#pragma mark Declaration

#define L3_OVERLOADABLE __attribute__((overloadable)) static inline
#define L3_CONSTRUCTOR __attribute__((constructor)) static inline
#define L3_EXTERN extern
#define L3_INLINE static inline


#pragma mark Configuration

#if defined(DEBUG)

// DEBUG=1 implies L3_DEBUG=1, unless L3_DEBUG has already been set (e.g. in a -D compiler flag)
#ifndef L3_DEBUG
#define L3_DEBUG 1
#endif

#endif // DEBUG

/*
 L3_DEBUG is intended to be defined in a Debug build configuration, for example when DEBUG=1 is defined (as is Xcode’s default).
 
 It automatically enables the compilation of tests.
 */
#if defined(L3_DEBUG)

// L3_DEBUG=1 implies L3_INCLUDE_TESTS=1, unless L3_INCLUDE_TESTS has already been set (e.g. in a -D compiler flag)
#ifndef L3_INCLUDE_TESTS
#define L3_INCLUDE_TESTS 1
#endif

#endif // L3_DEBUG


#pragma mark Boxing

#import <Lagrangian/metamacros.h>

L3_OVERLOADABLE id L3Box(id v) { return v; }
L3_OVERLOADABLE id L3Box(SEL v) { return NSStringFromSelector(v); }

#define l3_box_type_with_expression_literal(_, type) \
	L3_OVERLOADABLE id L3Box(type v) { return @(v); } \

metamacro_foreach(l3_box_type_with_expression_literal, ,
                  uint64_t, uint32_t, uint16_t, uint8_t,
                  int64_t, int32_t, int16_t, int8_t,
                  unsigned long,
                  signed long,
                  double, float,
                  bool,
                  const char *)
#undef l3_box_type_with_expression_literal

#define l3_box_type_with_NSValue(_, type) \
	L3_OVERLOADABLE id L3Box(type v) { return [NSValue valueWithBytes:&v objCType:@encode(__typeof__(v))]; } \

metamacro_foreach(l3_box_type_with_NSValue, ,
                  NSFastEnumerationState,
                  CGRect, CGSize, CGPoint, CGAffineTransform)
#undef l3_box_type_with_NSValue

#endif // L3_DEFINES_H

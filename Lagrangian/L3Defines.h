#ifndef L3_DEFINES_H
#define L3_DEFINES_H

#pragma mark Declaration

#define L3_OVERLOADABLE __attribute__((overloadable)) static inline
#define L3_CONSTRUCTOR __attribute((constructor)) static inline
#define L3_EXTERN extern


#pragma mark Metapreprocessing

#define L3_PASTE(a, b) a##b

#define L3_HEAD(head, ...) \
	head

#define L3_TAIL(head, ...) \
	__VA_ARGS__



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

L3_OVERLOADABLE id L3Box(id x) { return x; }

L3_OVERLOADABLE id L3Box(uint64_t v) { return @(v); }
L3_OVERLOADABLE id L3Box(uint32_t v) { return @(v); }
L3_OVERLOADABLE id L3Box(uint16_t v) { return @(v); }
L3_OVERLOADABLE id L3Box(uint8_t v) { return @(v); }
L3_OVERLOADABLE id L3Box(int64_t v) { return @(v); }
L3_OVERLOADABLE id L3Box(int32_t v) { return @(v); }
L3_OVERLOADABLE id L3Box(int16_t v) { return @(v); }
L3_OVERLOADABLE id L3Box(int8_t v) { return @(v); }
L3_OVERLOADABLE id L3Box(unsigned long v) { return @(v); }
L3_OVERLOADABLE id L3Box(signed long v) { return @(v); }
L3_OVERLOADABLE id L3Box(double v) { return @(v); }
L3_OVERLOADABLE id L3Box(float v) { return @(v); }
L3_OVERLOADABLE id L3Box(bool v) { return @(v); }
L3_OVERLOADABLE id L3Box(char *v) { return @(v); }

#endif // L3_DEFINES_H

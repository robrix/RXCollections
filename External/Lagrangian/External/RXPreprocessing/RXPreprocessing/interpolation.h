#ifndef __rx_interpolation__
#define __rx_interpolation__ 1

#import <Foundation/Foundation.h>
#include <RXPreprocessing/fold.h>

/**
 Formats and concatenates its arguments as an NSString according to their types. For example, you can use this in places where you would have used +[NSString stringWithFormat:] and had to decide the types of the parameters for the format string manually.
 
 	NSArray *objects = …;
 	NSUInteger index = …;
 	NSString *formatted = rx_q("The object at index ", index, " is: ", objects[index]);
 
 `rx_q` formats its arguments individually with `rx_f` (with no format qualifiers), and thus can format any type which `rx_f` supports.
 */

#define rx_q(...) \
	([@[rx_fold(_rx_q_format_each, @"", __VA_ARGS__)] componentsJoinedByString:@""])


/**
 Formats `value` as an NSString according to its type and the qualifiers specified in format. For example, `rx_f(, "")` will produce an empty NSString, while rx_f(4., "") will produce a four-space string.
 
 `rx_f` can be used within `rx_q` to customize the formatting of a single value within the longer interpolation.
 
 `rx_f` can format values of the following types:
 
 - signed and unsigned integers, including int32_t, uint32_t, int64_t, uint64_t, NSInteger, and NSUInteger, with smaller integers automatically getting promoted to 32-bit by C’s rules
 - doubles and floats
 - Objective-C objects
 - C strings
 - pointers, which are formatted with %p (thanks to @boredzo for the correction)
 */

#define rx_f(format, value) \
	((^NSString *{ \
		__typeof__(value) _rx_cached_value = (value); \
		return [NSString stringWithFormat:[NSString stringWithFormat:@"%%%s%@", #format, _rx_format_type_specifier_for_value(_rx_cached_value)], _rx_cached_value]; \
	})())


/**
 Prints a logging message whose parameters are formatted with `rx_q`. Uses NSLog to actually print the message.
*/
#define RXLog(...) \
	NSLog(@"%@", rx_q(__VA_ARGS__))


__attribute__((overloadable)) static inline NSString *_rx_format_type_specifier_for_value(NSUInteger x) { return @"lu"; }
__attribute__((overloadable)) static inline NSString *_rx_format_type_specifier_for_value(NSInteger x) { return @"li"; }

__attribute__((overloadable)) static inline NSString *_rx_format_type_specifier_for_value(uint64_t x) { return @"lu"; }
__attribute__((overloadable)) static inline NSString *_rx_format_type_specifier_for_value(int64_t x) { return @"li"; }

__attribute__((overloadable)) static inline NSString *_rx_format_type_specifier_for_value(uint32_t x) { return @"u"; }
__attribute__((overloadable)) static inline NSString *_rx_format_type_specifier_for_value(int32_t x) { return @"i"; }

__attribute__((overloadable)) static inline NSString *_rx_format_type_specifier_for_value(void *x) { return @"p"; }

__attribute__((overloadable)) static inline NSString *_rx_format_type_specifier_for_value(double x) { return @"f"; }
__attribute__((overloadable)) static inline NSString *_rx_format_type_specifier_for_value(float x) { return @"f"; }

__attribute__((overloadable)) static inline NSString *_rx_format_type_specifier_for_value(char *x) { return @"s"; }

__attribute__((overloadable)) static inline NSString *_rx_format_type_specifier_for_value(id x) { return @"@"; }

#define _rx_q_format_each(memo, each) rx_f(, each), memo

#endif // __rx_interpolation__

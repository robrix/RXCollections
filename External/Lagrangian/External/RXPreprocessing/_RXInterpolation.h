#ifndef _RX_INTERPOLATION_INCLUDED
#define _RX_INTERPOLATION_INCLUDED

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

#define _rx_value(x) \
	(x)

#define _rx_q_format_each(memo, each) rx_f(, each), memo

#endif

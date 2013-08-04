#ifndef __rx_count__
#define __rx_count__ 1

#include <RXPreprocessing/bool.h>
#include <RXPreprocessing/concat.h>
#include <RXPreprocessing/cond.h>
#include <RXPreprocessing/list.h>
#include <RXPreprocessing/test.h>

#pragma mark Variadic counting

/**
 0 if arguments are passed, 1 otherwise.
 */
#define rx_empty(...) \
	_rx_empty( \
		_rx_non_empty(__VA_ARGS__), \
		_rx_non_empty(_rx_comma __VA_ARGS__), \
		_rx_non_empty(__VA_ARGS__ (/**/)), \
		_rx_non_empty(_rx_comma __VA_ARGS__ (/**/)) \
	)
#define _rx_empty(_0, _1, _2, _3) rx_concat(_rx_empty_, rx_concat(_0, rx_concat(_1, rx_concat(_2, _3))))
#define _rx_empty_0000 0
#define _rx_empty_0001 1
#define _rx_empty_0010 0
#define _rx_empty_0011 0
#define _rx_empty_0100 0
#define _rx_empty_0101 0
#define _rx_empty_0110 0
#define _rx_empty_0111 0
#define _rx_empty_1000 0
#define _rx_empty_1001 0
#define _rx_empty_1010 0
#define _rx_empty_1011 0
#define _rx_empty_1100 0
#define _rx_empty_1101 0
#define _rx_empty_1110 0
#define _rx_empty_1111 0
#define _rx_non_empty(...) rx_at(31, __VA_ARGS__, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, )
#define _rx_comma(...) ,

/**
 1 if arguments are passed, 0 otherwise.
 */
#define rx_full(...) rx_not(rx_empty(__VA_ARGS__))

rx_static_test(rx_empty(/**/) == 1);
rx_static_test(rx_empty() == 1);
rx_static_test(rx_empty(a) == 0);
rx_static_test(rx_empty(b, c) == 0);

/**
 Returns the count of the (up to 32) arguments passed.
 */
#define rx_count(...) \
	rx_if_else(rx_empty(__VA_ARGS__), 0, rx_at(31, __VA_ARGS__, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0))

rx_static_test(rx_count() == 0);
rx_static_test(rx_count(a) == 1);
rx_static_test(rx_count(a, b) == 2);
rx_static_test(rx_count(a, b, c) == 3);
rx_static_test(rx_count(a, b, c, d, e) == 5);
rx_static_test(rx_count(a, (b, c), d, e) == 4);

#endif // __rx_count__

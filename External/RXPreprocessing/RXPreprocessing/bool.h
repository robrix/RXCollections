#ifndef __rx_bool__
#define __rx_bool__ 1

#include <RXPreprocessing/concat.h>

#pragma mark Boolean values

/**
 Returns 0 for 0, 1 otherwise.
 */
#define rx_bool(x) _rx_bool(x)
#define _rx_bool(x) rx_concat(_rx_bool_, x)
#define _rx_bool_0 0
#define _rx_bool_1 1
#define _rx_bool_2 1
#define _rx_bool_3 1
#define _rx_bool_4 1
#define _rx_bool_5 1
#define _rx_bool_6 1
#define _rx_bool_7 1
#define _rx_bool_8 1
#define _rx_bool_9 1
#define _rx_bool_10 1
#define _rx_bool_11 1
#define _rx_bool_12 1
#define _rx_bool_13 1
#define _rx_bool_14 1
#define _rx_bool_15 1
#define _rx_bool_16 1
#define _rx_bool_17 1
#define _rx_bool_18 1
#define _rx_bool_19 1
#define _rx_bool_20 1
#define _rx_bool_21 1
#define _rx_bool_22 1
#define _rx_bool_23 1
#define _rx_bool_24 1
#define _rx_bool_25 1
#define _rx_bool_26 1
#define _rx_bool_27 1
#define _rx_bool_28 1
#define _rx_bool_29 1
#define _rx_bool_30 1
#define _rx_bool_31 1
#define _rx_bool_32 1

#pragma mark Boolean algebra

/**
 Boolean not operator.
 */
#define rx_not(x) rx_concat(_rx_not_, rx_bool(x))
#define _rx_not_0 1
#define _rx_not_1 0

/**
 Boolean or operator.
 */
#define rx_or(x, y) rx_concat(_rx_or_, rx_concat(rx_bool(x), rx_bool(y)))
#define _rx_or_00 0
#define _rx_or_01 1
#define _rx_or_10 1
#define _rx_or_11 1

/**
 Boolean and operator.
 */
#define rx_and(x, y) rx_concat(_rx_and_, rx_concat(rx_bool(x), rx_bool(y)))
#define _rx_and_00 0
#define _rx_and_01 0
#define _rx_and_10 0
#define _rx_and_11 1

/**
 Boolean xor operator.
 */
#define rx_xor(x, y) rx_concat(_rx_xor_, rx_concat(rx_bool(x), rx_bool(y)))
#define _rx_xor_00 0
#define _rx_xor_01 1
#define _rx_xor_10 1
#define _rx_xor_11 0

#endif // __rx_bool__

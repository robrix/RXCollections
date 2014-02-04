#ifndef __rx_compare__
#define __rx_compare__ 1

#include <RXPreprocessing/bool.h>
#include <RXPreprocessing/concat.h>
#include <RXPreprocessing/math.h>
#include <RXPreprocessing/test.h>

#define rx_eq(x, y) rx_not(rx_bool(rx_subtract(x, y)))
#define _rx_eq_0 1
#define _rx_eq_1 0
#define _rx_eq_2 0
#define _rx_eq_3 0

/**
 x < y
 */
#define rx_lt(x, y) rx_concat(_rx_lt_, y)(x)


#pragma mark Tests

rx_static_test(rx_eq(0, 0) == 1);
//rx_static_test(rx_eq(0, 1) == 0);
rx_static_test(rx_eq(1, 0) == 0);
rx_static_test(rx_eq(1, 1) == 1);

#endif // __rx_compare__

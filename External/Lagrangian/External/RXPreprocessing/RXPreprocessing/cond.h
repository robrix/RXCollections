#ifndef __rx_cond__
#define __rx_cond__ 1

#include <RXPreprocessing/bool.h>

#pragma mark Conditionals

/**
 Evaluates to x if cond is true, or y otherwise.
 */
#define rx_if_else(cond, x, y) _rx_if_else(cond, x, y)
#define _rx_if_else(cond, x, y) rx_concat(_rx_if_else_, rx_bool(cond))(x, y)
#define _rx_if_else_0(x, y) y
#define _rx_if_else_1(x, y) x

/**
 Evaluates to x if cond is true, or the empty token otherwise.
 */
#define rx_if(cond, x) rx_if_else(cond, x, )

#endif // __rx_cond__

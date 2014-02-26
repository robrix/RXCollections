#ifndef __rx_concat__
#define __rx_concat__ 1

#pragma mark Concatenation

/**
 Concatenates its arguments to form a single token.
 */
#define rx_concat(x, y) _rx_concat(x, y)
#define _rx_concat(x, y) x##y

#endif // __rx_concat__

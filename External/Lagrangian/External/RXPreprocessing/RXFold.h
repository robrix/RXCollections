#ifndef RX_FOLD_INCLUDED
#define RX_FOLD_INCLUDED

#include "RXCount.h"
#include "RXPaste.h"
#include "_RXFold.h"

/**
`rx_fold(f, initial, ...)`

Folds the varargs with the macro specified as the first argument. This macro must take two arguments: the first being the result thus far, and the second being the current element in the varargs. `initial` provides the value for the first invocation of `f` (when there are no results yet provided).

Use it like this:

	#define add(x, y) y + x
	int sum = rx_fold(add, 0, 1, 2, 3, 4, 5); → int sum = 0 + 1 + 2 + 3 + 4 + 5 + 6;
*/

#define rx_fold(f, initial, ...) \
	_rx_fold(f, initial, rx_count(__VA_ARGS__), __VA_ARGS__)

#endif

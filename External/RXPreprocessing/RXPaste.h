#ifndef RX_PASTE_INCLUDED
#define RX_PASTE_INCLUDED

/**
`rx_paste(a, b)`

Pastes the tokens a and b together into a single token.
*/

#define rx_paste(_1, _2) \
	_rx_paste(_1, _2)

#define _rx_paste(_1, _2) \
	_1##_2

#endif

//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <float.h>

#if defined(__LP64__) && __LP64__

#define RX_MAGNITUDE_TYPE double
#define RX_MAGNITUDE_IS_DOUBLE 1
#define RX_MAGNITUDE_MIN DBL_MIN
#define RX_MAGNITUDE_MAX DBL_MAX

#else

#define RX_MAGNITUDE_TYPE float
#define RX_MAGNITUDE_IS_DOUBLE 0
#define RX_MAGNITUDE_MIN FLT_MIN
#define RX_MAGNITUDE_MAX FLT_MAX

#endif

typedef RX_MAGNITUDE_TYPE RXMagnitude;
#define RX_MAGNITUDE_DEFINED 1

/**
 Computes the absolute value of \c x.
 
 \param x A magnitude to compute the absolute value of.
 \return The absolute value of \x.
 */
static inline RXMagnitude RXMagnitudeGetAbsoluteValue(RXMagnitude x);
static inline RXMagnitude RXMagnitudeGetAbsoluteValue(RXMagnitude x) {
#if RX_MAGNITUDE_IS_DOUBLE
	return fabs(x);
#else
	return fabsf(x);
#endif
}

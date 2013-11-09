# RXPreprocessing

Metaprogramming and metapreprocessing utilities for the enterprising developer. Featuring old standbys and novelties alike, including:

- good old token pasting — concat.h
- variadic argument counting — count.h
- differentiating between >=1- and 0-argument lists — count.h
- boolean algebra, including NOT, OR, AND, and XOR — bool.h
- conditional expressions — cond.h
- left and right folds — fold.h
- maps — map.h
- arithmetic — math.h (incomplete)

Except where otherwise noted, these utilities are standard, cross-platform use of the C preprocessor, and do not rely on e.g. GNU extensions.

## RXInterpolation.h

Preprocessor-based interpolation of NSStrings. This allows you to interpolate complex strings without requiring you to remember which format specifier you want for each. You can still, however, customize the formatting of each individual parameter to specify precision or width.

Requires Foundation, and uses `__attribute__((overloadable))` functions to generate the type specifiers for the format strings, since clang’s support for C11’s `_Generic` expressions appears to have difficulty when both `char *` and `default` options are added.

Some things you can do with it:

	NSUInteger waysILoveThee = kLotsOfWays;
	RXLog(@"How do I love thee? Let me count the ways: ", waysILoveThee);

Inspired by @pgor, who nerd-sniped me one fine morning.

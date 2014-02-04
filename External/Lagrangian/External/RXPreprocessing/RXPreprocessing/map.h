#ifndef __rx_map__
#define __rx_map__ 1

#include <RXPreprocessing/concat.h>
#include <RXPreprocessing/count.h>
#include <RXPreprocessing/test.h>

#define rx_comma(x, y) x, y
#define rx_space(x, y) x y
#define rx_semicolon(x, y) x ; y

#define rx_statement_map(f, ...) rx_map(rx_semicolon, f, __VA_ARGS__)

/**
 Maps the variadic arguments with the macro specified as f; combines the mapped results with the macro specified as g.
 */

#define rx_map(g, f, ...) \
	_rx_map(g, f, rx_count(__VA_ARGS__), __VA_ARGS__)
#define _rx_map(g, f, n, ...) \
	rx_concat(_rx_map_, n)(g, f, __VA_ARGS__)

// ruby -e '2.upto(64).each {|n| puts "#define _rx_map_#{n}(g, f, each, ...)\t\tg(f(each), _rx_map_#{n-1}(g, f, __VA_ARGS__))"}'

#define _rx_map_1(g, f, x)				f(x)
#define _rx_map_2(g, f, each, ...)		g(f(each), _rx_map_1(g, f, __VA_ARGS__))
#define _rx_map_3(g, f, each, ...)		g(f(each), _rx_map_2(g, f, __VA_ARGS__))
#define _rx_map_4(g, f, each, ...)		g(f(each), _rx_map_3(g, f, __VA_ARGS__))
#define _rx_map_5(g, f, each, ...)		g(f(each), _rx_map_4(g, f, __VA_ARGS__))
#define _rx_map_6(g, f, each, ...)		g(f(each), _rx_map_5(g, f, __VA_ARGS__))
#define _rx_map_7(g, f, each, ...)		g(f(each), _rx_map_6(g, f, __VA_ARGS__))
#define _rx_map_8(g, f, each, ...)		g(f(each), _rx_map_7(g, f, __VA_ARGS__))
#define _rx_map_9(g, f, each, ...)		g(f(each), _rx_map_8(g, f, __VA_ARGS__))
#define _rx_map_10(g, f, each, ...)		g(f(each), _rx_map_9(g, f, __VA_ARGS__))
#define _rx_map_11(g, f, each, ...)		g(f(each), _rx_map_10(g, f, __VA_ARGS__))
#define _rx_map_12(g, f, each, ...)		g(f(each), _rx_map_11(g, f, __VA_ARGS__))
#define _rx_map_13(g, f, each, ...)		g(f(each), _rx_map_12(g, f, __VA_ARGS__))
#define _rx_map_14(g, f, each, ...)		g(f(each), _rx_map_13(g, f, __VA_ARGS__))
#define _rx_map_15(g, f, each, ...)		g(f(each), _rx_map_14(g, f, __VA_ARGS__))
#define _rx_map_16(g, f, each, ...)		g(f(each), _rx_map_15(g, f, __VA_ARGS__))
#define _rx_map_17(g, f, each, ...)		g(f(each), _rx_map_16(g, f, __VA_ARGS__))
#define _rx_map_18(g, f, each, ...)		g(f(each), _rx_map_17(g, f, __VA_ARGS__))
#define _rx_map_19(g, f, each, ...)		g(f(each), _rx_map_18(g, f, __VA_ARGS__))
#define _rx_map_20(g, f, each, ...)		g(f(each), _rx_map_19(g, f, __VA_ARGS__))
#define _rx_map_21(g, f, each, ...)		g(f(each), _rx_map_20(g, f, __VA_ARGS__))
#define _rx_map_22(g, f, each, ...)		g(f(each), _rx_map_21(g, f, __VA_ARGS__))
#define _rx_map_23(g, f, each, ...)		g(f(each), _rx_map_22(g, f, __VA_ARGS__))
#define _rx_map_24(g, f, each, ...)		g(f(each), _rx_map_23(g, f, __VA_ARGS__))
#define _rx_map_25(g, f, each, ...)		g(f(each), _rx_map_24(g, f, __VA_ARGS__))
#define _rx_map_26(g, f, each, ...)		g(f(each), _rx_map_25(g, f, __VA_ARGS__))
#define _rx_map_27(g, f, each, ...)		g(f(each), _rx_map_26(g, f, __VA_ARGS__))
#define _rx_map_28(g, f, each, ...)		g(f(each), _rx_map_27(g, f, __VA_ARGS__))
#define _rx_map_29(g, f, each, ...)		g(f(each), _rx_map_28(g, f, __VA_ARGS__))
#define _rx_map_30(g, f, each, ...)		g(f(each), _rx_map_29(g, f, __VA_ARGS__))
#define _rx_map_31(g, f, each, ...)		g(f(each), _rx_map_30(g, f, __VA_ARGS__))
#define _rx_map_32(g, f, each, ...)		g(f(each), _rx_map_31(g, f, __VA_ARGS__))
#define _rx_map_33(g, f, each, ...)		g(f(each), _rx_map_32(g, f, __VA_ARGS__))
#define _rx_map_34(g, f, each, ...)		g(f(each), _rx_map_33(g, f, __VA_ARGS__))
#define _rx_map_35(g, f, each, ...)		g(f(each), _rx_map_34(g, f, __VA_ARGS__))
#define _rx_map_36(g, f, each, ...)		g(f(each), _rx_map_35(g, f, __VA_ARGS__))
#define _rx_map_37(g, f, each, ...)		g(f(each), _rx_map_36(g, f, __VA_ARGS__))
#define _rx_map_38(g, f, each, ...)		g(f(each), _rx_map_37(g, f, __VA_ARGS__))
#define _rx_map_39(g, f, each, ...)		g(f(each), _rx_map_38(g, f, __VA_ARGS__))
#define _rx_map_40(g, f, each, ...)		g(f(each), _rx_map_39(g, f, __VA_ARGS__))
#define _rx_map_41(g, f, each, ...)		g(f(each), _rx_map_40(g, f, __VA_ARGS__))
#define _rx_map_42(g, f, each, ...)		g(f(each), _rx_map_41(g, f, __VA_ARGS__))
#define _rx_map_43(g, f, each, ...)		g(f(each), _rx_map_42(g, f, __VA_ARGS__))
#define _rx_map_44(g, f, each, ...)		g(f(each), _rx_map_43(g, f, __VA_ARGS__))
#define _rx_map_45(g, f, each, ...)		g(f(each), _rx_map_44(g, f, __VA_ARGS__))
#define _rx_map_46(g, f, each, ...)		g(f(each), _rx_map_45(g, f, __VA_ARGS__))
#define _rx_map_47(g, f, each, ...)		g(f(each), _rx_map_46(g, f, __VA_ARGS__))
#define _rx_map_48(g, f, each, ...)		g(f(each), _rx_map_47(g, f, __VA_ARGS__))
#define _rx_map_49(g, f, each, ...)		g(f(each), _rx_map_48(g, f, __VA_ARGS__))
#define _rx_map_50(g, f, each, ...)		g(f(each), _rx_map_49(g, f, __VA_ARGS__))
#define _rx_map_51(g, f, each, ...)		g(f(each), _rx_map_50(g, f, __VA_ARGS__))
#define _rx_map_52(g, f, each, ...)		g(f(each), _rx_map_51(g, f, __VA_ARGS__))
#define _rx_map_53(g, f, each, ...)		g(f(each), _rx_map_52(g, f, __VA_ARGS__))
#define _rx_map_54(g, f, each, ...)		g(f(each), _rx_map_53(g, f, __VA_ARGS__))
#define _rx_map_55(g, f, each, ...)		g(f(each), _rx_map_54(g, f, __VA_ARGS__))
#define _rx_map_56(g, f, each, ...)		g(f(each), _rx_map_55(g, f, __VA_ARGS__))
#define _rx_map_57(g, f, each, ...)		g(f(each), _rx_map_56(g, f, __VA_ARGS__))
#define _rx_map_58(g, f, each, ...)		g(f(each), _rx_map_57(g, f, __VA_ARGS__))
#define _rx_map_59(g, f, each, ...)		g(f(each), _rx_map_58(g, f, __VA_ARGS__))
#define _rx_map_60(g, f, each, ...)		g(f(each), _rx_map_59(g, f, __VA_ARGS__))
#define _rx_map_61(g, f, each, ...)		g(f(each), _rx_map_60(g, f, __VA_ARGS__))
#define _rx_map_62(g, f, each, ...)		g(f(each), _rx_map_61(g, f, __VA_ARGS__))
#define _rx_map_63(g, f, each, ...)		g(f(each), _rx_map_62(g, f, __VA_ARGS__))
#define _rx_map_64(g, f, each, ...)		g(f(each), _rx_map_63(g, f, __VA_ARGS__))


#pragma mark Tests

#define _rx_square(x) (x * x)
#define _rx_sum(sum, x) (sum + x)

rx_static_test(rx_map(_rx_sum, _rx_square, 1) == 1);
rx_static_test(rx_map(_rx_sum, _rx_square, 1, 2) == 5);
rx_static_test(rx_map(_rx_sum, _rx_square, 1, 2, 3) == 14);
rx_static_test(rx_map(_rx_sum, _rx_square, 1, 2, 3, 4) == 30);
rx_static_test(rx_map(_rx_sum, _rx_square, 1, 2, 3, 4, 5) == 55);

#undef _rx_square
#undef _rx_sum

#endif

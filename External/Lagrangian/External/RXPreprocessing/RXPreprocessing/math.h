#ifndef __rx_math__
#define __rx_math__ 1

#include <RXPreprocessing/list.h>
#include <RXPreprocessing/count.h>
#include <RXPreprocessing/test.h>

#define rx_increment(x) \
	rx_at(x, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65)

#define rx_decrement(x) \
	rx_at(x, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63)


#define rx_comma(x, y) x, y
#define rx_identity(x) x

#define rx_add(x, y) \
	rx_power(rx_increment, x, y)

#define rx_subtract(x, y) \
	rx_power(rx_decrement, y, x)

#define rx_power(f, n, ...) rx_concat(_rx_power_, n)(f, __VA_ARGS__)

// ruby -e '2.upto(64).each {|n| puts "#define _rx_power_#{n}(f, ...)\t\tf(_rx_power_#{n-1}(f, __VA_ARGS__))"}'

#define _rx_power_0(f, ...)			__VA_ARGS__
#define _rx_power_1(f, ...)			f(__VA_ARGS__)
#define _rx_power_2(f, ...)			f(_rx_power_1(f, __VA_ARGS__))
#define _rx_power_3(f, ...)			f(_rx_power_2(f, __VA_ARGS__))
#define _rx_power_4(f, ...)			f(_rx_power_3(f, __VA_ARGS__))
#define _rx_power_5(f, ...)			f(_rx_power_4(f, __VA_ARGS__))
#define _rx_power_6(f, ...)			f(_rx_power_5(f, __VA_ARGS__))
#define _rx_power_7(f, ...)			f(_rx_power_6(f, __VA_ARGS__))
#define _rx_power_8(f, ...)			f(_rx_power_7(f, __VA_ARGS__))
#define _rx_power_9(f, ...)			f(_rx_power_8(f, __VA_ARGS__))
#define _rx_power_10(f, ...)		f(_rx_power_9(f, __VA_ARGS__))
#define _rx_power_11(f, ...)		f(_rx_power_10(f, __VA_ARGS__))
#define _rx_power_12(f, ...)		f(_rx_power_11(f, __VA_ARGS__))
#define _rx_power_13(f, ...)		f(_rx_power_12(f, __VA_ARGS__))
#define _rx_power_14(f, ...)		f(_rx_power_13(f, __VA_ARGS__))
#define _rx_power_15(f, ...)		f(_rx_power_14(f, __VA_ARGS__))
#define _rx_power_16(f, ...)		f(_rx_power_15(f, __VA_ARGS__))
#define _rx_power_17(f, ...)		f(_rx_power_16(f, __VA_ARGS__))
#define _rx_power_18(f, ...)		f(_rx_power_17(f, __VA_ARGS__))
#define _rx_power_19(f, ...)		f(_rx_power_18(f, __VA_ARGS__))
#define _rx_power_20(f, ...)		f(_rx_power_19(f, __VA_ARGS__))
#define _rx_power_21(f, ...)		f(_rx_power_20(f, __VA_ARGS__))
#define _rx_power_22(f, ...)		f(_rx_power_21(f, __VA_ARGS__))
#define _rx_power_23(f, ...)		f(_rx_power_22(f, __VA_ARGS__))
#define _rx_power_24(f, ...)		f(_rx_power_23(f, __VA_ARGS__))
#define _rx_power_25(f, ...)		f(_rx_power_24(f, __VA_ARGS__))
#define _rx_power_26(f, ...)		f(_rx_power_25(f, __VA_ARGS__))
#define _rx_power_27(f, ...)		f(_rx_power_26(f, __VA_ARGS__))
#define _rx_power_28(f, ...)		f(_rx_power_27(f, __VA_ARGS__))
#define _rx_power_29(f, ...)		f(_rx_power_28(f, __VA_ARGS__))
#define _rx_power_30(f, ...)		f(_rx_power_29(f, __VA_ARGS__))
#define _rx_power_31(f, ...)		f(_rx_power_30(f, __VA_ARGS__))
#define _rx_power_32(f, ...)		f(_rx_power_31(f, __VA_ARGS__))
#define _rx_power_33(f, ...)		f(_rx_power_32(f, __VA_ARGS__))
#define _rx_power_34(f, ...)		f(_rx_power_33(f, __VA_ARGS__))
#define _rx_power_35(f, ...)		f(_rx_power_34(f, __VA_ARGS__))
#define _rx_power_36(f, ...)		f(_rx_power_35(f, __VA_ARGS__))
#define _rx_power_37(f, ...)		f(_rx_power_36(f, __VA_ARGS__))
#define _rx_power_38(f, ...)		f(_rx_power_37(f, __VA_ARGS__))
#define _rx_power_39(f, ...)		f(_rx_power_38(f, __VA_ARGS__))
#define _rx_power_40(f, ...)		f(_rx_power_39(f, __VA_ARGS__))
#define _rx_power_41(f, ...)		f(_rx_power_40(f, __VA_ARGS__))
#define _rx_power_42(f, ...)		f(_rx_power_41(f, __VA_ARGS__))
#define _rx_power_43(f, ...)		f(_rx_power_42(f, __VA_ARGS__))
#define _rx_power_44(f, ...)		f(_rx_power_43(f, __VA_ARGS__))
#define _rx_power_45(f, ...)		f(_rx_power_44(f, __VA_ARGS__))
#define _rx_power_46(f, ...)		f(_rx_power_45(f, __VA_ARGS__))
#define _rx_power_47(f, ...)		f(_rx_power_46(f, __VA_ARGS__))
#define _rx_power_48(f, ...)		f(_rx_power_47(f, __VA_ARGS__))
#define _rx_power_49(f, ...)		f(_rx_power_48(f, __VA_ARGS__))
#define _rx_power_50(f, ...)		f(_rx_power_49(f, __VA_ARGS__))
#define _rx_power_51(f, ...)		f(_rx_power_50(f, __VA_ARGS__))
#define _rx_power_52(f, ...)		f(_rx_power_51(f, __VA_ARGS__))
#define _rx_power_53(f, ...)		f(_rx_power_52(f, __VA_ARGS__))
#define _rx_power_54(f, ...)		f(_rx_power_53(f, __VA_ARGS__))
#define _rx_power_55(f, ...)		f(_rx_power_54(f, __VA_ARGS__))
#define _rx_power_56(f, ...)		f(_rx_power_55(f, __VA_ARGS__))
#define _rx_power_57(f, ...)		f(_rx_power_56(f, __VA_ARGS__))
#define _rx_power_58(f, ...)		f(_rx_power_57(f, __VA_ARGS__))
#define _rx_power_59(f, ...)		f(_rx_power_58(f, __VA_ARGS__))
#define _rx_power_60(f, ...)		f(_rx_power_59(f, __VA_ARGS__))
#define _rx_power_61(f, ...)		f(_rx_power_60(f, __VA_ARGS__))
#define _rx_power_62(f, ...)		f(_rx_power_61(f, __VA_ARGS__))
#define _rx_power_63(f, ...)		f(_rx_power_62(f, __VA_ARGS__))
#define _rx_power_64(f, ...)		f(_rx_power_63(f, __VA_ARGS__))


#pragma mark Tests

rx_static_test(rx_increment(0) == 1);
rx_static_test(rx_increment(1) == 2);
rx_static_test(rx_decrement(0) == -1);

rx_static_test(rx_subtract(7, 5) == 2);
rx_static_test(rx_subtract(5, 6) == -1);

rx_static_test(rx_add(0, 0) == 0);
rx_static_test(rx_add(0, 1) == 1);
rx_static_test(rx_add(1, 0) == 1);
rx_static_test(rx_add(1, 1) == 2);
rx_static_test(rx_add(0, 2) == 2);
rx_static_test(rx_add(2, 0) == 2);
rx_static_test(rx_add(1, 2) == 3);
rx_static_test(rx_add(2, 1) == 3);
rx_static_test(rx_add(2, 2) == 4);

rx_static_test(rx_power(rx_increment, 2, 3) == 5);

#endif // __rx_math__

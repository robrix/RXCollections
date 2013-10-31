#ifndef __rx_list__
#define __rx_list__ 1

#include <RXPreprocessing/concat.h>
#include <RXPreprocessing/test.h>

#pragma mark Lists

#define rx_head(...) _rx_head(__VA_ARGS__)
#define _rx_head(x, ...) x

#define rx_tail(...) _rx_tail(__VA_ARGS__)
#define _rx_tail(x, ...) __VA_ARGS__

#define rx_at(N, ...) rx_concat(_rx_at_, N)(__VA_ARGS__)

#define _rx_at_0(...) rx_head(__VA_ARGS__)
#define _rx_at_1(_0, ...) rx_head(__VA_ARGS__)
#define _rx_at_2(_0, _1, ...) rx_head(__VA_ARGS__)
#define _rx_at_3(_0, _1, _2, ...) rx_head(__VA_ARGS__)
#define _rx_at_4(_0, _1, _2, _3, ...) rx_head(__VA_ARGS__)
#define _rx_at_5(_0, _1, _2, _3, _4, ...) rx_head(__VA_ARGS__)
#define _rx_at_6(_0, _1, _2, _3, _4, _5, ...) rx_head(__VA_ARGS__)
#define _rx_at_7(_0, _1, _2, _3, _4, _5, _6, ...) rx_head(__VA_ARGS__)
#define _rx_at_8(_0, _1, _2, _3, _4, _5, _6, _7, ...) rx_head(__VA_ARGS__)
#define _rx_at_9(_0, _1, _2, _3, _4, _5, _6, _7, _8, ...) rx_head(__VA_ARGS__)
#define _rx_at_10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, ...) rx_head(__VA_ARGS__)
#define _rx_at_11(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, ...) rx_head(__VA_ARGS__)
#define _rx_at_12(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, ...) rx_head(__VA_ARGS__)
#define _rx_at_13(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, ...) rx_head(__VA_ARGS__)
#define _rx_at_14(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, ...) rx_head(__VA_ARGS__)
#define _rx_at_15(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, ...) rx_head(__VA_ARGS__)
#define _rx_at_16(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, ...) rx_head(__VA_ARGS__)
#define _rx_at_17(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, ...) rx_head(__VA_ARGS__)
#define _rx_at_18(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, ...) rx_head(__VA_ARGS__)
#define _rx_at_19(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, ...) rx_head(__VA_ARGS__)
#define _rx_at_20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, ...) rx_head(__VA_ARGS__)
#define _rx_at_21(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, ...) rx_head(__VA_ARGS__)
#define _rx_at_22(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21, ...) rx_head(__VA_ARGS__)
#define _rx_at_23(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21, _22, ...) rx_head(__VA_ARGS__)
#define _rx_at_24(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21, _22, _23, ...) rx_head(__VA_ARGS__)
#define _rx_at_25(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21, _22, _23, _24, ...) rx_head(__VA_ARGS__)
#define _rx_at_26(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21, _22, _23, _24, _25, ...) rx_head(__VA_ARGS__)
#define _rx_at_27(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21, _22, _23, _24, _25, _26, ...) rx_head(__VA_ARGS__)
#define _rx_at_28(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21, _22, _23, _24, _25, _26, _27, ...) rx_head(__VA_ARGS__)
#define _rx_at_29(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, ...) rx_head(__VA_ARGS__)
#define _rx_at_30(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, ...) rx_head(__VA_ARGS__)
#define _rx_at_31(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, ...) rx_head(__VA_ARGS__)
#define _rx_at_32(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, ...) rx_head(__VA_ARGS__)
#define _rx_at_33(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, ...) rx_head(__VA_ARGS__)

#define rx_repeat(g, f, n) \
	rx_concat(_rx_repeat_, n)(g, f)

// ruby -e '2.upto(64).each {|n| puts "#define _rx_repeat_#{n}(g, f)\t\tg(_rx_repeat_#{n-1}(g, f), f(#{n}))"}'

#define _rx_repeat_0(g, f)		0
#define _rx_repeat_1(g, f)		f(1)
#define _rx_repeat_2(g, f)		g(_rx_repeat_1(g, f), f(2))
#define _rx_repeat_3(g, f)		g(_rx_repeat_2(g, f), f(3))
#define _rx_repeat_4(g, f)		g(_rx_repeat_3(g, f), f(4))
#define _rx_repeat_5(g, f)		g(_rx_repeat_4(g, f), f(5))
#define _rx_repeat_6(g, f)		g(_rx_repeat_5(g, f), f(6))
#define _rx_repeat_7(g, f)		g(_rx_repeat_6(g, f), f(7))
#define _rx_repeat_8(g, f)		g(_rx_repeat_7(g, f), f(8))
#define _rx_repeat_9(g, f)		g(_rx_repeat_8(g, f), f(9))
#define _rx_repeat_10(g, f)		g(_rx_repeat_9(g, f), f(10))
#define _rx_repeat_11(g, f)		g(_rx_repeat_10(g, f), f(11))
#define _rx_repeat_12(g, f)		g(_rx_repeat_11(g, f), f(12))
#define _rx_repeat_13(g, f)		g(_rx_repeat_12(g, f), f(13))
#define _rx_repeat_14(g, f)		g(_rx_repeat_13(g, f), f(14))
#define _rx_repeat_15(g, f)		g(_rx_repeat_14(g, f), f(15))
#define _rx_repeat_16(g, f)		g(_rx_repeat_15(g, f), f(16))
#define _rx_repeat_17(g, f)		g(_rx_repeat_16(g, f), f(17))
#define _rx_repeat_18(g, f)		g(_rx_repeat_17(g, f), f(18))
#define _rx_repeat_19(g, f)		g(_rx_repeat_18(g, f), f(19))
#define _rx_repeat_20(g, f)		g(_rx_repeat_19(g, f), f(20))
#define _rx_repeat_21(g, f)		g(_rx_repeat_20(g, f), f(21))
#define _rx_repeat_22(g, f)		g(_rx_repeat_21(g, f), f(22))
#define _rx_repeat_23(g, f)		g(_rx_repeat_22(g, f), f(23))
#define _rx_repeat_24(g, f)		g(_rx_repeat_23(g, f), f(24))
#define _rx_repeat_25(g, f)		g(_rx_repeat_24(g, f), f(25))
#define _rx_repeat_26(g, f)		g(_rx_repeat_25(g, f), f(26))
#define _rx_repeat_27(g, f)		g(_rx_repeat_26(g, f), f(27))
#define _rx_repeat_28(g, f)		g(_rx_repeat_27(g, f), f(28))
#define _rx_repeat_29(g, f)		g(_rx_repeat_28(g, f), f(29))
#define _rx_repeat_30(g, f)		g(_rx_repeat_29(g, f), f(30))
#define _rx_repeat_31(g, f)		g(_rx_repeat_30(g, f), f(31))
#define _rx_repeat_32(g, f)		g(_rx_repeat_31(g, f), f(32))
#define _rx_repeat_33(g, f)		g(_rx_repeat_32(g, f), f(33))
#define _rx_repeat_34(g, f)		g(_rx_repeat_33(g, f), f(34))
#define _rx_repeat_35(g, f)		g(_rx_repeat_34(g, f), f(35))
#define _rx_repeat_36(g, f)		g(_rx_repeat_35(g, f), f(36))
#define _rx_repeat_37(g, f)		g(_rx_repeat_36(g, f), f(37))
#define _rx_repeat_38(g, f)		g(_rx_repeat_37(g, f), f(38))
#define _rx_repeat_39(g, f)		g(_rx_repeat_38(g, f), f(39))
#define _rx_repeat_40(g, f)		g(_rx_repeat_39(g, f), f(40))
#define _rx_repeat_41(g, f)		g(_rx_repeat_40(g, f), f(41))
#define _rx_repeat_42(g, f)		g(_rx_repeat_41(g, f), f(42))
#define _rx_repeat_43(g, f)		g(_rx_repeat_42(g, f), f(43))
#define _rx_repeat_44(g, f)		g(_rx_repeat_43(g, f), f(44))
#define _rx_repeat_45(g, f)		g(_rx_repeat_44(g, f), f(45))
#define _rx_repeat_46(g, f)		g(_rx_repeat_45(g, f), f(46))
#define _rx_repeat_47(g, f)		g(_rx_repeat_46(g, f), f(47))
#define _rx_repeat_48(g, f)		g(_rx_repeat_47(g, f), f(48))
#define _rx_repeat_49(g, f)		g(_rx_repeat_48(g, f), f(49))
#define _rx_repeat_50(g, f)		g(_rx_repeat_49(g, f), f(50))
#define _rx_repeat_51(g, f)		g(_rx_repeat_50(g, f), f(51))
#define _rx_repeat_52(g, f)		g(_rx_repeat_51(g, f), f(52))
#define _rx_repeat_53(g, f)		g(_rx_repeat_52(g, f), f(53))
#define _rx_repeat_54(g, f)		g(_rx_repeat_53(g, f), f(54))
#define _rx_repeat_55(g, f)		g(_rx_repeat_54(g, f), f(55))
#define _rx_repeat_56(g, f)		g(_rx_repeat_55(g, f), f(56))
#define _rx_repeat_57(g, f)		g(_rx_repeat_56(g, f), f(57))
#define _rx_repeat_58(g, f)		g(_rx_repeat_57(g, f), f(58))
#define _rx_repeat_59(g, f)		g(_rx_repeat_58(g, f), f(59))
#define _rx_repeat_60(g, f)		g(_rx_repeat_59(g, f), f(60))
#define _rx_repeat_61(g, f)		g(_rx_repeat_60(g, f), f(61))
#define _rx_repeat_62(g, f)		g(_rx_repeat_61(g, f), f(62))
#define _rx_repeat_63(g, f)		g(_rx_repeat_62(g, f), f(63))
#define _rx_repeat_64(g, f)		g(_rx_repeat_63(g, f), f(64))


#pragma mark Tests

#define _rx_sum(sum, x) (sum + x)
#define _rx_square(x) (x * x)

rx_static_test(rx_repeat(_rx_sum, _rx_square, 4) == 30);
rx_static_test(rx_repeat(_rx_sum, _rx_square, 5) == 55);

#undef _rx_square
#undef _rx_sum

#endif // __rx_list__

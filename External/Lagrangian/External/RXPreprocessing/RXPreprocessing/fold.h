#ifndef __rx_fold__
#define __rx_fold__ 1

#include <RXPreprocessing/concat.h>
#include <RXPreprocessing/count.h>
#include <RXPreprocessing/test.h>

#pragma mark foldr

/**
 Folds the variadic arguments with the macro specified as the first argument. This macro must take two arguments: the first being the result thus far, and the second being the current element in the varargs. `initial` provides the value for the first invocation of `f` (when there are no results yet provided).
 
 Use it like this:
 
 	#define add(memo, each) (each + memo)
 	int sum = rx_fold(add, 0, 1, 2, 3, 4, 5); → int sum = (1 + (2 + (3 + (4 + (5 + 0)))));
 */

#define rx_fold(f, initial, ...) rx_foldr(f, initial, __VA_ARGS__)

#define rx_foldr(f, initial, ...) \
	_rx_foldr(f, initial, rx_count(__VA_ARGS__), __VA_ARGS__)
#define _rx_foldr(f, initial, n, ...) \
	rx_concat(_rx_foldr_, n)(f, initial, __VA_ARGS__)

#define rx_foldl(f, initial, ...) \
	_rx_foldl(f, initial, rx_count(__VA_ARGS__), __VA_ARGS__)
#define _rx_foldl(f, initial, n, ...) \
	rx_concat(_rx_foldl_, n)(f, initial, __VA_ARGS__)

// ruby -e '2.upto(64).each {|n| puts "#define _rx_foldr_#{n}(f, memo, each, ...)\t\tf(_rx_foldr_#{n-1}(f, memo, __VA_ARGS__), each)"}'

#define _rx_foldr_0(f, memo, _)					memo
#define _rx_foldr_1(f, memo, each)				f(memo, each)
#define _rx_foldr_2(f, memo, each, ...)			f(_rx_foldr_1(f, memo, __VA_ARGS__), each)
#define _rx_foldr_3(f, memo, each, ...)			f(_rx_foldr_2(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_4(f, memo, each, ...)			f(_rx_foldr_3(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_5(f, memo, each, ...)			f(_rx_foldr_4(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_6(f, memo, each, ...)			f(_rx_foldr_5(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_7(f, memo, each, ...)			f(_rx_foldr_6(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_8(f, memo, each, ...)			f(_rx_foldr_7(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_9(f, memo, each, ...)			f(_rx_foldr_8(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_10(f, memo, each, ...)		f(_rx_foldr_9(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_11(f, memo, each, ...)		f(_rx_foldr_10(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_12(f, memo, each, ...)		f(_rx_foldr_11(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_13(f, memo, each, ...)		f(_rx_foldr_12(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_14(f, memo, each, ...)		f(_rx_foldr_13(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_15(f, memo, each, ...)		f(_rx_foldr_14(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_16(f, memo, each, ...)		f(_rx_foldr_15(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_17(f, memo, each, ...)		f(_rx_foldr_16(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_18(f, memo, each, ...)		f(_rx_foldr_17(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_19(f, memo, each, ...)		f(_rx_foldr_18(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_20(f, memo, each, ...)		f(_rx_foldr_19(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_21(f, memo, each, ...)		f(_rx_foldr_20(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_22(f, memo, each, ...)		f(_rx_foldr_21(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_23(f, memo, each, ...)		f(_rx_foldr_22(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_24(f, memo, each, ...)		f(_rx_foldr_23(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_25(f, memo, each, ...)		f(_rx_foldr_24(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_26(f, memo, each, ...)		f(_rx_foldr_25(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_27(f, memo, each, ...)		f(_rx_foldr_26(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_28(f, memo, each, ...)		f(_rx_foldr_27(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_29(f, memo, each, ...)		f(_rx_foldr_28(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_30(f, memo, each, ...)		f(_rx_foldr_29(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_31(f, memo, each, ...)		f(_rx_foldr_30(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_32(f, memo, each, ...)		f(_rx_foldr_31(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_33(f, memo, each, ...)		f(_rx_foldr_32(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_34(f, memo, each, ...)		f(_rx_foldr_33(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_35(f, memo, each, ...)		f(_rx_foldr_34(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_36(f, memo, each, ...)		f(_rx_foldr_35(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_37(f, memo, each, ...)		f(_rx_foldr_36(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_38(f, memo, each, ...)		f(_rx_foldr_37(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_39(f, memo, each, ...)		f(_rx_foldr_38(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_40(f, memo, each, ...)		f(_rx_foldr_39(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_41(f, memo, each, ...)		f(_rx_foldr_40(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_42(f, memo, each, ...)		f(_rx_foldr_41(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_43(f, memo, each, ...)		f(_rx_foldr_42(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_44(f, memo, each, ...)		f(_rx_foldr_43(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_45(f, memo, each, ...)		f(_rx_foldr_44(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_46(f, memo, each, ...)		f(_rx_foldr_45(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_47(f, memo, each, ...)		f(_rx_foldr_46(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_48(f, memo, each, ...)		f(_rx_foldr_47(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_49(f, memo, each, ...)		f(_rx_foldr_48(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_50(f, memo, each, ...)		f(_rx_foldr_49(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_51(f, memo, each, ...)		f(_rx_foldr_50(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_52(f, memo, each, ...)		f(_rx_foldr_51(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_53(f, memo, each, ...)		f(_rx_foldr_52(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_54(f, memo, each, ...)		f(_rx_foldr_53(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_55(f, memo, each, ...)		f(_rx_foldr_54(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_56(f, memo, each, ...)		f(_rx_foldr_55(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_57(f, memo, each, ...)		f(_rx_foldr_56(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_58(f, memo, each, ...)		f(_rx_foldr_57(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_59(f, memo, each, ...)		f(_rx_foldr_58(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_60(f, memo, each, ...)		f(_rx_foldr_59(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_61(f, memo, each, ...)		f(_rx_foldr_60(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_62(f, memo, each, ...)		f(_rx_foldr_61(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_63(f, memo, each, ...)		f(_rx_foldr_62(f, memo,  __VA_ARGS__), each)
#define _rx_foldr_64(f, memo, each, ...)		f(_rx_foldr_63(f, memo,  __VA_ARGS__), each)


#pragma mark foldl

// ruby -e '2.upto(64).each {|n| puts "#define _rx_foldl_#{n}(f, memo, each, ...)\t\t_rx_foldl_#{n-1}(f, f(each, memo), __VA_ARGS__)"}'

#define _rx_foldl_0(f, memo, _)					memo
#define _rx_foldl_1(f, memo, each)				f(each, memo)
#define _rx_foldl_2(f, memo, each, ...)			_rx_foldl_1(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_3(f, memo, each, ...)			_rx_foldl_2(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_4(f, memo, each, ...)			_rx_foldl_3(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_5(f, memo, each, ...)			_rx_foldl_4(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_6(f, memo, each, ...)			_rx_foldl_5(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_7(f, memo, each, ...)			_rx_foldl_6(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_8(f, memo, each, ...)			_rx_foldl_7(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_9(f, memo, each, ...)			_rx_foldl_8(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_10(f, memo, each, ...)		_rx_foldl_9(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_11(f, memo, each, ...)		_rx_foldl_10(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_12(f, memo, each, ...)		_rx_foldl_11(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_13(f, memo, each, ...)		_rx_foldl_12(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_14(f, memo, each, ...)		_rx_foldl_13(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_15(f, memo, each, ...)		_rx_foldl_14(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_16(f, memo, each, ...)		_rx_foldl_15(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_17(f, memo, each, ...)		_rx_foldl_16(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_18(f, memo, each, ...)		_rx_foldl_17(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_19(f, memo, each, ...)		_rx_foldl_18(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_20(f, memo, each, ...)		_rx_foldl_19(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_21(f, memo, each, ...)		_rx_foldl_20(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_22(f, memo, each, ...)		_rx_foldl_21(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_23(f, memo, each, ...)		_rx_foldl_22(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_24(f, memo, each, ...)		_rx_foldl_23(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_25(f, memo, each, ...)		_rx_foldl_24(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_26(f, memo, each, ...)		_rx_foldl_25(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_27(f, memo, each, ...)		_rx_foldl_26(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_28(f, memo, each, ...)		_rx_foldl_27(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_29(f, memo, each, ...)		_rx_foldl_28(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_30(f, memo, each, ...)		_rx_foldl_29(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_31(f, memo, each, ...)		_rx_foldl_30(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_32(f, memo, each, ...)		_rx_foldl_31(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_33(f, memo, each, ...)		_rx_foldl_32(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_34(f, memo, each, ...)		_rx_foldl_33(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_35(f, memo, each, ...)		_rx_foldl_34(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_36(f, memo, each, ...)		_rx_foldl_35(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_37(f, memo, each, ...)		_rx_foldl_36(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_38(f, memo, each, ...)		_rx_foldl_37(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_39(f, memo, each, ...)		_rx_foldl_38(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_40(f, memo, each, ...)		_rx_foldl_39(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_41(f, memo, each, ...)		_rx_foldl_40(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_42(f, memo, each, ...)		_rx_foldl_41(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_43(f, memo, each, ...)		_rx_foldl_42(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_44(f, memo, each, ...)		_rx_foldl_43(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_45(f, memo, each, ...)		_rx_foldl_44(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_46(f, memo, each, ...)		_rx_foldl_45(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_47(f, memo, each, ...)		_rx_foldl_46(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_48(f, memo, each, ...)		_rx_foldl_47(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_49(f, memo, each, ...)		_rx_foldl_48(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_50(f, memo, each, ...)		_rx_foldl_49(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_51(f, memo, each, ...)		_rx_foldl_50(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_52(f, memo, each, ...)		_rx_foldl_51(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_53(f, memo, each, ...)		_rx_foldl_52(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_54(f, memo, each, ...)		_rx_foldl_53(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_55(f, memo, each, ...)		_rx_foldl_54(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_56(f, memo, each, ...)		_rx_foldl_55(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_57(f, memo, each, ...)		_rx_foldl_56(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_58(f, memo, each, ...)		_rx_foldl_57(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_59(f, memo, each, ...)		_rx_foldl_58(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_60(f, memo, each, ...)		_rx_foldl_59(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_61(f, memo, each, ...)		_rx_foldl_60(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_62(f, memo, each, ...)		_rx_foldl_61(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_63(f, memo, each, ...)		_rx_foldl_62(f, f(each, memo), __VA_ARGS__)
#define _rx_foldl_64(f, memo, each, ...)		_rx_foldl_63(f, f(each, memo), __VA_ARGS__)


#pragma mark Tests

#define _rx_add(memo, each) (each + memo)
#define _rx_subtract(memo, each) (each - memo)

rx_static_test(rx_foldr(_rx_add, 0, 1, 2, 3, 4, 5) == 15);
rx_static_test(rx_foldl(_rx_add, 0, 1, 2, 3, 4, 5) == 15);
rx_static_test(rx_foldr(_rx_subtract, 0, 1, 2, 3, 4, 5) == 3);
rx_static_test(rx_foldr(_rx_subtract, 0, 1, 2, 3, 4, 5) == (1 - (2 - (3 - (4 - (5 - 0))))));
rx_static_test(rx_foldl(_rx_subtract, 0, 1, 2, 3, 4, 5) == -15);
rx_static_test(rx_foldl(_rx_subtract, 0, 1, 2, 3, 4, 5) == (((((0 - 1) - 2) - 3) - 4) - 5));

rx_static_test(rx_foldr(_rx_subtract, 0, 0) == 0);
rx_static_test(rx_foldl(_rx_subtract, 0, 0) == 0);

#undef _rx_add
#undef _rx_subtract

#endif // __rx_fold__

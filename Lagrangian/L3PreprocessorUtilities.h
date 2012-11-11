//  L3PreprocessorUtilities.h
//  Created by Rob Rix on 2012-11-10.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#pragma mark -
#pragma mark Macro utilities

#define l3_domain						com_antitypical_lagrangian_
#define l3_identifier(sym, line)		l3_paste(l3_paste(l3_domain, sym), line)

#define l3_paste(a, b)					l3_paste_implementation(a, b)
#define l3_paste_implementation(a, b)	a##b

#define l3_string(x)					l3_string_implementation(x)
#define l3_string_implementation(x)		#x

#pragma mark -
#pragma mark bool

#define l3_bool(x)						l3_bool_implementation(x)
#define l3_bool_implementation(x)		l3_paste(l3_bool_, x)
#define l3_bool_0						0
#define l3_bool_1						1
#define l3_bool_2						1
#define l3_bool_3						1
#define l3_bool_4						1
#define l3_bool_5						1
#define l3_bool_6						1
#define l3_bool_7						1
#define l3_bool_8						1
#define l3_bool_9						1
#define l3_bool_10						1
#define l3_bool_11						1
#define l3_bool_12						1
#define l3_bool_13						1
#define l3_bool_14						1
#define l3_bool_15						1
#define l3_bool_16						1
#define l3_bool_17						1
#define l3_bool_18						1
#define l3_bool_19						1
#define l3_bool_20						1
#define l3_bool_21						1
#define l3_bool_22						1
#define l3_bool_23						1
#define l3_bool_24						1
#define l3_bool_25						1
#define l3_bool_26						1
#define l3_bool_27						1
#define l3_bool_28						1
#define l3_bool_29						1
#define l3_bool_30						1
#define l3_bool_31						1


#pragma mark -
#pragma mark Variadic folding

#define l3_fold(f, ...) \
	l3_fold_implementation(f, l3_count(__VA_ARGS__), __VA_ARGS__)
#define l3_fold_implementation(f, n, ...) \
	l3_paste(l3_fold_, n)(f, __VA_ARGS__)

#define l3_fold_1(f, each)				f(each)
#define l3_fold_2(f, each, ...)			l3_fold_1(f, each) l3_fold_1(f, __VA_ARGS__)
#define l3_fold_3(f, each, ...)			l3_fold_1(f, each) l3_fold_2(f, __VA_ARGS__)
#define l3_fold_4(f, each, ...)			l3_fold_1(f, each) l3_fold_3(f, __VA_ARGS__)
#define l3_fold_5(f, each, ...)			l3_fold_1(f, each) l3_fold_4(f, __VA_ARGS__)
#define l3_fold_6(f, each, ...)			l3_fold_1(f, each) l3_fold_5(f, __VA_ARGS__)
#define l3_fold_7(f, each, ...)			l3_fold_1(f, each) l3_fold_6(f, __VA_ARGS__)
#define l3_fold_8(f, each, ...)			l3_fold_1(f, each) l3_fold_7(f, __VA_ARGS__)
#define l3_fold_9(f, each, ...)			l3_fold_1(f, each) l3_fold_8(f, __VA_ARGS__)
#define l3_fold_10(f, each, ...)		l3_fold_1(f, each) l3_fold_9(f, __VA_ARGS__)
#define l3_fold_11(f, each, ...)		l3_fold_1(f, each) l3_fold_10(f, __VA_ARGS__)
#define l3_fold_12(f, each, ...)		l3_fold_1(f, each) l3_fold_11(f, __VA_ARGS__)
#define l3_fold_13(f, each, ...)		l3_fold_1(f, each) l3_fold_12(f, __VA_ARGS__)
#define l3_fold_14(f, each, ...)		l3_fold_1(f, each) l3_fold_13(f, __VA_ARGS__)
#define l3_fold_15(f, each, ...)		l3_fold_1(f, each) l3_fold_14(f, __VA_ARGS__)
#define l3_fold_16(f, each, ...)		l3_fold_1(f, each) l3_fold_15(f, __VA_ARGS__)
#define l3_fold_17(f, each, ...)		l3_fold_1(f, each) l3_fold_16(f, __VA_ARGS__)
#define l3_fold_18(f, each, ...)		l3_fold_1(f, each) l3_fold_17(f, __VA_ARGS__)
#define l3_fold_19(f, each, ...)		l3_fold_1(f, each) l3_fold_18(f, __VA_ARGS__)
#define l3_fold_20(f, each, ...)		l3_fold_1(f, each) l3_fold_19(f, __VA_ARGS__)
#define l3_fold_21(f, each, ...)		l3_fold_1(f, each) l3_fold_20(f, __VA_ARGS__)
#define l3_fold_22(f, each, ...)		l3_fold_1(f, each) l3_fold_21(f, __VA_ARGS__)
#define l3_fold_23(f, each, ...)		l3_fold_1(f, each) l3_fold_22(f, __VA_ARGS__)
#define l3_fold_24(f, each, ...)		l3_fold_1(f, each) l3_fold_23(f, __VA_ARGS__)
#define l3_fold_25(f, each, ...)		l3_fold_1(f, each) l3_fold_24(f, __VA_ARGS__)
#define l3_fold_26(f, each, ...)		l3_fold_1(f, each) l3_fold_25(f, __VA_ARGS__)
#define l3_fold_27(f, each, ...)		l3_fold_1(f, each) l3_fold_26(f, __VA_ARGS__)
#define l3_fold_28(f, each, ...)		l3_fold_1(f, each) l3_fold_27(f, __VA_ARGS__)
#define l3_fold_29(f, each, ...)		l3_fold_1(f, each) l3_fold_28(f, __VA_ARGS__)
#define l3_fold_30(f, each, ...)		l3_fold_1(f, each) l3_fold_29(f, __VA_ARGS__)
#define l3_fold_31(f, each, ...)		l3_fold_1(f, each) l3_fold_30(f, __VA_ARGS__)
#define l3_fold_32(f, each, ...)		l3_fold_1(f, each) l3_fold_31(f, __VA_ARGS__)


#pragma mark -
#pragma mark Conditional macro expansion

#define l3_cond(cond, then, else)		l3_cond_implementation(cond, then, else)
#define l3_cond_implementation(cond, then, else) \
	l3_paste(l3_cond_, l3_bool(cond))(then, else)
#define l3_cond_0(x, y)					y
#define l3_cond_1(x, y)					x


#pragma mark -
#pragma mark - Variadic counting

#define l3_count(...) \
	l3_count_implementation(_0, ## __VA_ARGS__, l3_reverse_ordinals())
#define l3_count_implementation(...) \
	l3_ordinals(__VA_ARGS__)
#define l3_ordinals( \
	_0, \
	_1, _2, _3, _4, _5, _6, _7, _8, _9,_10, \
	_11,_12,_13,_14,_15,_16,_17,_18,_19,_20, \
	_21,_22,_23,_24,_25,_26,_27,_28,_29,_30, \
	_31,_32,_33,_34,_35,_36,_37,_38,_39,_40, \
	_41,_42,_43,_44,_45,_46,_47,_48,_49,_50, \
	_51,_52,_53,_54,_55,_56,_57,_58,_59,_60, \
	_61,_62,_63,  N,...) N
#define l3_reverse_ordinals() \
	63, 62, 61, 60,                         \
	59, 58, 57, 56, 55, 54, 53, 52, 51, 50, \
	49, 48, 47, 46, 45, 44, 43, 42, 41, 40, \
	39, 38, 37, 36, 35, 34, 33, 32, 31, 30, \
	29, 28, 27, 26, 25, 24, 23, 22, 21, 20, \
	19, 18, 17, 16, 15, 14, 13, 12, 11, 10, \
	9,  8,  7,  6,  5,  4,  3,  2,  1,  0

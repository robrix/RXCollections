//  L3PreprocessorUtilities.h
//  Created by Rob Rix on 2012-11-10.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Lagrangian/RXPaste.h>

#pragma mark Macro utilities

#define l3_domain						com_antitypical_lagrangian_
#define l3_identifier(sym, line)		rx_paste(rx_paste(l3_domain, sym), line)

#define l3_string(x)					l3_string_implementation(x)
#define l3_string_implementation(x)		#x

#pragma mark bool

#define l3_bool(x)						l3_bool_implementation(x)
#define l3_bool_implementation(x)		rx_paste(l3_bool_, x)
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


#pragma mark Conditional macro expansion

#define l3_cond(cond, then, else)		l3_cond_implementation(cond, then, else)
#define l3_cond_implementation(cond, then, else) \
	rx_paste(l3_cond_, l3_bool(cond))(then, else)
#define l3_cond_0(x, y)					y
#define l3_cond_1(x, y)					x

//  L3TestState.m
//  Created by Rob Rix on 2012-11-10.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TestState.h"

@implementation L3TestState

//static bool l3_sel_takesArguments(SEL selector) {
//	return [NSStringFromSelector(selector) rangeOfString:@":"].length != 0;
//}

// - forwarding for foo and set foo
// - can this specialize for bool? maybe detect has/is/did/should/etc?
// - do the properties we declare in categories actually show up anywhere at runtime?
// - cache method impls during forwarding
// - dynamically subclass per-suite

@end

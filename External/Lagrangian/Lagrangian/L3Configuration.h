//  L3Configuration.h
//  Created by Rob Rix on 2012-12-24.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

#pragma mark Configuration macros

#if DEBUG

// DEBUG=1 implies L3_DEBUG=1, unless L3_DEBUG has already been set (e.g. in a -D compiler flag)
#ifndef L3_DEBUG
#define L3_DEBUG 1
#endif

#endif

/*
 L3_DEBUG is intended to be defined in a Debug build configuration, for example when DEBUG=1 is defined (as is Xcode’s default).
 
 It automatically enables the compilation of tests.
 */
#if L3_DEBUG

// L3_DEBUG=1 implies L3_INCLUDE_TESTS=1, unless L3_INCLUDE_TESTS has already been set (e.g. in a -D compiler flag)
#ifndef L3_INCLUDE_TESTS
#define L3_INCLUDE_TESTS 1
#endif

#endif

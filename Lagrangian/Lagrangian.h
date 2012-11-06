//
//  Lagrangian.h
//  Lagrangian
//
//  Created by Rob Rix on 2012-11-05.
//  Copyright (c) 2012 Rob Rix. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark -
#pragma mark Test suites

#define l3suite(str) \
	class L3TestSuite;



#pragma mark -
#pragma mark Test cases

#define l3test(str) \
	class L3TestSuite, L3TestCase; \
	\
	static void l3identifier(test_case_, __LINE__)(L3TestSuite *suite, L3TestCase *self); \
	\
	__attribute__((constructor)) static void l3identifier(test_loader_, __LINE__)() { \
		l3identifier(test_case_, __LINE__)(nil, nil); \
	} \
	\
	static void l3identifier(test_case_, __LINE__)(L3TestSuite *suite, L3TestCase *self)



#pragma mark -
#pragma mark Macro utilities

#define l3domain					com_antitypical_lagrangian_
#define l3identifier(sym, line)		l3paste(l3paste(l3domain, sym), line)

#define l3paste(a, b)				l3paste2(a, b)
#define l3paste2(a, b)				a##b

//  L3Types.h
//  Created by Rob Rix on 2012-11-08.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@class L3TestCase;
@class L3TestSuite;
@class L3TestState;

typedef void(*L3TestCaseFunction)(L3TestState *, L3TestSuite *, L3TestCase *);
typedef L3TestCaseFunction L3TestCaseSetUpFunction;
typedef L3TestCaseFunction L3TestCaseTearDownFunction;

typedef void(^L3TestCaseBlock)(L3TestState *, L3TestSuite *, L3TestCase *);

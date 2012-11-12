//  L3TestContext.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import "L3Types.h"

@protocol L3TestContext <NSObject>

@property (strong, nonatomic, readonly) Class stateClass;

// test steps will go here

@property (assign, nonatomic, readonly) L3TestCaseSetUpFunction setUpFunction;
@property (assign, nonatomic, readonly) L3TestCaseTearDownFunction tearDownFunction;

@end

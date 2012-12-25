//  L3TestRunner.h
//  Created by Rob Rix on 2012-11-09.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@class L3TestSuite;

@interface L3TestRunner : NSObject

+(bool)shouldRunTestsAtLaunch;
+(bool)isRunningInApplication;

+(instancetype)runner;

-(void)run; // starts running asynchronously
-(void)waitForTestsToComplete;

@end

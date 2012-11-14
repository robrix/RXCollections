//  L3TestResultFormatter.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3EventObserver.h"

@protocol L3TestResultFormatterDelegate;

@protocol L3TestResultFormatter <L3EventObserver>

@property (weak, nonatomic) id<L3TestResultFormatterDelegate> delegate;

@end

@class L3TestResult;

@protocol L3TestResultFormatterDelegate <NSObject>

-(void)formatter:(id<L3TestResultFormatter>)formatter didFormatEventWithResultString:(NSString *)string;
-(void)formatter:(id<L3TestResultFormatter>)formatter didFinishFormattingEventsWithFinalTestResult:(L3TestResult *)testResult;

@end

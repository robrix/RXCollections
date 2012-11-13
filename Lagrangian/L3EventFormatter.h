//  L3EventFormatter.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3EventAlgebra.h"

@protocol L3EventFormatterDelegate;

@protocol L3EventFormatter <L3EventAlgebra>

@property (weak, nonatomic) id<L3EventFormatterDelegate> delegate;

@end

@class L3TestResult;

@protocol L3EventFormatterDelegate <NSObject>

-(void)formatter:(id<L3EventFormatter>)formatter didFormatEventWithResultString:(NSString *)string;
-(void)formatter:(id<L3EventFormatter>)formatter didFinishFormattingEventsWithFinalTestResult:(L3TestResult *)testResult;

@end

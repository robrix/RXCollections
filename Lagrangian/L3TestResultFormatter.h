//  L3TestResultFormatter.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Lagrangian/L3TestResultBuilder.h>

@protocol L3TestResultFormatterDelegate;

@protocol L3TestResultFormatter <L3TestResultBuilderDelegate>

@property (weak, nonatomic) id<L3TestResultFormatterDelegate> delegate;

@end

@class L3TestResult;

@protocol L3TestResultFormatterDelegate <NSObject>

-(void)formatter:(id<L3TestResultFormatter>)formatter didFormatResult:(L3TestResult *)result asString:(NSString *)string;

@end

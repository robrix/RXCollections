//  NSException+L3OCUnitCompatibility.h
//  Created by Rob Rix on 7/22/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@interface NSException (L3OCUnitCompatibility)

@property (nonatomic, readonly) NSString *filename;
@property (nonatomic, readonly) NSNumber *lineNumber;

+(NSException *)failureInFile:(NSString *)filename atLine:(int)lineNumber withDescription:(NSString *)formatString, ... NS_FORMAT_FUNCTION(3, 4);

@end

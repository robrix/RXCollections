//  NSException+L3OCUnitCompatibility.m
//  Created by Rob Rix on 7/22/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "NSException+L3OCUnitCompatibility.h"

@implementation NSException (L3OCUnitCompatibility)

-(NSString *)filename {
	return self.userInfo[NSStringFromSelector(_cmd)];
}

-(NSNumber *)lineNumber {
	return self.userInfo[NSStringFromSelector(_cmd)];
}


+(NSException *)failureInFile:(NSString *)filename atLine:(int)lineNumber withDescription:(NSString *)formatString, ... {
	NSString *description = nil;
	if (formatString) {
		va_list arguments;
		va_start(arguments, formatString);
		description = [[NSString alloc] initWithFormat:formatString arguments:arguments];
		va_end(arguments);
	}
	
	return [NSException exceptionWithName:@"L3Exception" reason:description userInfo:@{
																					   @"filename": filename,
																					   @"lineNumber": @(lineNumber),
																					   }];
}

@end

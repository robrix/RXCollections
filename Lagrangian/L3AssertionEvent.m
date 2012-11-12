//  L3AssertionEvent.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3AssertionEvent.h"

@implementation L3AssertionEvent

#pragma mark -
#pragma mark Constructors

+(instancetype)eventWithFile:(NSString *)file line:(NSUInteger)line actualValue:(NSString *)actualValue expectedPattern:(NSString *)expectedPattern source:(id<L3EventSource>)source {
	return [[self alloc] initWithFile:file line:line actualValue:actualValue expectedPattern:expectedPattern source:source];
}

-(instancetype)initWithFile:(NSString *)file line:(NSUInteger)line actualValue:(NSString *)actualValue expectedPattern:(NSString *)expectedPattern source:(id<L3EventSource>)source {
	if ((self = [super initWithSource:source])) {
		_file = file;
		_line = line;
		
		_actualValue = actualValue;
		_expectedPattern = expectedPattern;
	}
	return self;
}

@end

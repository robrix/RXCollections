//  L3SourceReference.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3SourceReference.h"

@implementation L3SourceReference

#pragma mark Constructors

+(instancetype)referenceWithFile:(NSString *)file line:(NSUInteger)line subjectSource:(NSString *)subjectSource subject:(id)subject patternSource:(NSString *)patternSource {
	return [[self alloc] initWithFile:file line:line subjectSource:subjectSource subject:subject patternSource:patternSource];
}

+(instancetype)referenceWithFile:(NSString *)file line:(NSUInteger)line reason:(NSString *)reason {
	return [[self alloc] initWithFile:file line:line reason:reason];
}

-(instancetype)initWithFile:(NSString *)file line:(NSUInteger)line reason:(NSString *)reason {
	if ((self = [super init])) {
		_file = [file copy];
		_line = line;
		_reason = [reason copy];
	}
	return self;
}

-(instancetype)initWithFile:(NSString *)file line:(NSUInteger)line subjectSource:(NSString *)subjectSource subject:(id)subject patternSource:(NSString *)patternSource {
	if ((self = [self initWithFile:file line:line reason:[NSString stringWithFormat:@"'%@' was '%@' but should have matched '%@'", subjectSource, subject, patternSource]])) {
		_subjectSource = [subjectSource copy];
		_subject = subject;
		_patternSource = [patternSource copy];
	}
	return self;
}


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	return self;
}

@end

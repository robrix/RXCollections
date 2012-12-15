//  L3SourceReference.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3SourceReference.h"

@implementation L3SourceReference

#pragma mark Constructors

+(instancetype)referenceWithFile:(NSString *)file line:(NSUInteger)line subjectSource:(NSString *)subjectSource subject:(id)subject patternSource:(NSString *)patternSource {
	return [[self alloc] initWithFile:file line:line subjectSource:subjectSource subject:subject patternSource:patternSource];
}

-(instancetype)initWithFile:(NSString *)file line:(NSUInteger)line subjectSource:(NSString *)subjectSource subject:(id)subject patternSource:(NSString *)patternSource {
	if ((self = [super init])) {
		_file = [file copy];
		_line = line;
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

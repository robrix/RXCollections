//  L3SourceReference.h
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@interface L3SourceReference : NSObject <NSCopying>

+(instancetype)referenceWithFile:(NSString *)file line:(NSUInteger)line subjectSource:(NSString *)subjectSource subject:(id)subject patternSource:(NSString *)patternSource;
+(instancetype)referenceWithFile:(NSString *)file line:(NSUInteger)line reason:(NSString *)reason;

@property (copy, nonatomic, readonly) NSString *file;
@property (assign, nonatomic, readonly) NSUInteger line;

@property (copy, nonatomic, readonly) NSString *reason;

@property (copy, nonatomic, readonly) NSString *subjectSource;
@property (strong, nonatomic, readonly) id subject;
@property (copy, nonatomic, readonly) NSString *patternSource;

@end

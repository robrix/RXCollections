#ifndef L3_SOURCE_REFERENCE_H
#define L3_SOURCE_REFERENCE_H

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import <Lagrangian/L3Defines.h>


@protocol L3SourceReference <NSObject, NSCopying>

@property (nonatomic, readonly) id identifier;

@property (nonatomic, readonly) NSString *file;
@property (nonatomic, readonly) NSUInteger line;

@property (nonatomic, readonly) NSString *subjectSource;
@property (nonatomic, readonly) id subject;

@end


#define l3_source_reference(...) \
	L3SourceReferenceCreate(@(__COUNTER__), @(__FILE__), __LINE__, @(#__VA_ARGS__), L3Box(__VA_ARGS__))

L3_EXTERN id<L3SourceReference> L3SourceReferenceCreate(id identifier, NSString *file, NSUInteger line, NSString *subjectSource, id subject);

#endif // L3_SOURCE_REFERENCE_H

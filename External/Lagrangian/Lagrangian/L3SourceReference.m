#import "L3SourceReference.h"

@interface L3SourceReference : NSObject <L3SourceReference>
@end

@implementation L3SourceReference

#pragma mark Constructors

-(instancetype)initWithIdentifier:(id)identifier file:(NSString *)file line:(NSUInteger)line subjectSource:(NSString *)subjectSource subject:(id)subject {
	if ((self = [super init])) {
		_identifier = identifier;
		
		_file = [file copy];
		_line = line;
		
		_subjectSource = [subjectSource copy];
		_subject = subject;
	}
	return self;
}


#pragma mark L3SourceReference

@synthesize
	identifier = _identifier,
	file = _file,
	line = _line,

	subjectSource = _subjectSource,
	subject = _subject;


#pragma mark NSCopying

-(instancetype)copyWithZone:(NSZone *)zone {
	return self;
}

@end


id<L3SourceReference> L3SourceReferenceCreate(id identifier, NSString *file, NSUInteger line, NSString *subjectSource, id subject) {
	return [[L3SourceReference alloc] initWithIdentifier:identifier file:file line:line subjectSource:subjectSource subject:subject];
}

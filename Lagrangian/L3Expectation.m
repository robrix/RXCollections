#import "L3Expectation.h"
#import "L3SourceReference.h"
#import "L3Test.h"

@interface L3Predicate : NSObject <L3Predicate>

@property (nonatomic, strong) id<L3Predicate> nextPredicate;

@end

@implementation L3Predicate

-(instancetype)initWithExpectation:(id<L3Expectation>)expectation predicate:(NSPredicate *)predicate imperativePhrase:(NSString *)imperativePhrase {
	if ((self = [super init])) {
		_expectation = expectation;
		_predicate = predicate;
		_imperativePhrase = imperativePhrase;
	}
	return self;
}


#pragma mark L3Predicate

@synthesize
	expectation = _expectation,
	predicate = _predicate,
	imperativePhrase = _imperativePhrase;


-(bool)testWithSubject:(id)subject {
	NSDictionary *evaluatedObject = @{
		@"subject": subject,
		@"expectation": self.expectation,
		@"nextPredicate": @([self.nextPredicate testWithSubject:subject])
	};
	return [self.predicate evaluateWithObject:evaluatedObject];
}

@end


@interface L3Expectation : NSObject <L3Expectation>

@property (nonatomic, strong) id<L3Predicate> nextPredicate;
@property (nonatomic, strong) NSException *exception;

@property (nonatomic, copy) void(^completionHandler)(id<L3Expectation>, bool wasMet);

@end

@implementation L3Expectation

-(instancetype)initWithSubjectReference:(id<L3SourceReference>)subjectReference completionHandler:(void(^)(id<L3Expectation>, bool wasMet))completionHandler {
	if ((self = [super init])) {
		_subjectReference = subjectReference;
		_completionHandler = [completionHandler copy];
	}
	return self;
}


#pragma mark L3Expectation

@synthesize
	subjectReference = _subjectReference,
	nextPredicate = _nextPredicate;

-(id<L3Expectation>)to {
	return self;
}


-(bool(^)(id object))equal {
	;
	return ^bool(id object){
		NSString * const format = NSLocalizedString(@"equal %1$@", @"Format string for predicates' imperative phrases. %1$@ is a placeholder for the object.");
		self.nextPredicate = [[L3Predicate alloc] initWithExpectation:self predicate:[NSPredicate predicateWithFormat:@"subject == %@", object] imperativePhrase:[NSString stringWithFormat:format, object]];
		return [self test];
	};
}


-(bool)test {
	bool wasMet = NO;
	@try {
		wasMet = [self.nextPredicate testWithSubject:self.subjectReference.subject];
	}
	@catch (NSException *exception) {
		self.exception = exception;
	}
	@finally {
		self.completionHandler(self, wasMet);
		self.completionHandler = nil;
		self.exception = nil;
	}
	return wasMet;
}


-(NSString *)assertivePhrase {
	NSString * const format = NSLocalizedString(@"%1$@ should %2$@", @"Format string for expectations' assertive phrases. %1$@ is a placeholder for the source code of the subject. %2$@ is a placeholder for the predicate's imperative phrase.");
	return [NSString stringWithFormat:format, self.subjectReference.subjectSource, self.nextPredicate.imperativePhrase];
}

-(NSString *)indicativePhrase {
	NSString * const format = NSLocalizedString(@"%1$@ (%2$@) does not %3$@", @"Format string for expectations' indicative phrases (when failing). %1$@ is a placeholder for the subject's source code. %2$@ is a placeholder for the subject's description at runtime. %3$@ is a placeholder for the predicate's imperative phrase.");
	return [NSString stringWithFormat:format, self.subjectReference.subjectSource, [self.subjectReference.subject description], self.nextPredicate.imperativePhrase];
}

@end


L3Expectation *L3Expect(L3Test *test, void(^callback)(id<L3Expectation> expectation, bool wasMet), id<L3SourceReference> subjectReference) {
	return [[L3Expectation alloc] initWithSubjectReference:subjectReference completionHandler:callback];
}

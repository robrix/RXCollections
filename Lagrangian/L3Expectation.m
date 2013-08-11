#import "L3Expectation.h"
#import "L3SourceReference.h"
#import "L3Test.h"

#import "NSException+L3OCUnitCompatibility.h"

@interface L3TestResult : NSObject <L3TestResult>

@property (nonatomic) id<L3SourceReference> subjectReference;

@property (nonatomic) NSString *hypothesisString;
@property (nonatomic) NSString *observationString;

@property (nonatomic) bool wasMet;
@property (nonatomic) NSException *exception;

@end


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

@property (nonatomic, weak) L3Test *test;

@property (nonatomic) id<L3Predicate> nextPredicate;

@property (nonatomic, copy) void(^completionHandler)(id<L3Expectation>, bool wasMet);

@end

@implementation L3Expectation

-(instancetype)initWithSubjectReference:(id<L3SourceReference>)subjectReference {
	if ((self = [super init])) {
		_subjectReference = subjectReference;
	}
	return self;
}


#pragma mark L3Expectation

@synthesize subjectReference = _subjectReference;

-(id<L3Expectation>)to {
	return self;
}

//-(id<L3Expectation>)notTo {
//	return nil;
//}


-(bool(^)(id object))equal {
	return ^bool(id object){
		NSString *imperativePhrase = [NSString stringWithFormat:@"equal %@", object];
		self.nextPredicate = [[L3Predicate alloc] initWithExpectation:self predicate:[NSPredicate predicateWithFormat:@"subject == %@", object] imperativePhrase:imperativePhrase];
		return [self testExpectation];
	};
}


-(bool)testExpectation {
	bool wasMet = NO;
	NSException *unexpectedException = nil;
	@try {
		wasMet = [self.nextPredicate testWithSubject:self.subjectReference.subject];
	}
	@catch (NSException *exception) {
		unexpectedException = exception;
	}
	@finally {
		L3TestResult *result = [L3TestResult new];
		result.subjectReference = self.subjectReference;
		result.hypothesisString = self.assertivePhrase;
		result.observationString = self.indicativePhrase;
		result.wasMet = wasMet;
		result.exception = unexpectedException;
		[self.test expectation:self producedResult:result];
	}
	return wasMet;
}


-(NSString *)assertivePhrase {
	return [NSString stringWithFormat:@"%@ should %@", self.subjectReference.subjectSource, self.nextPredicate.imperativePhrase];
}

-(NSString *)indicativePhrase {
	return [NSString stringWithFormat:@"%@ (%@) does not %@", self.subjectReference.subjectSource, [self.subjectReference.subject description], self.nextPredicate.imperativePhrase];
}

@end


@implementation L3TestResult
@end


id<L3Expectation> L3Expect(L3Test *test, id<L3SourceReference> subjectReference) {
	L3Expectation *expectation = [[L3Expectation alloc] initWithSubjectReference:subjectReference];
	expectation.test = test;
	[test addExpectation:expectation];
	return expectation;
}

id<L3TestResult> L3TestResultCreateWithException(NSException *exception) {
	L3TestResult *result = [L3TestResult new];
	result.subjectReference = L3SourceReferenceCreate(nil, exception.filename, exception.lineNumber, nil, nil);
	result.hypothesisString = exception.reason;
	result.observationString = exception.reason;
	result.wasMet = NO;
	result.exception = nil;
	return result;
}

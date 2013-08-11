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


static inline NSString *L3InterpolateString(NSString *format, NSDictionary *values);
l3_test(&L3InterpolateString, ^{
	NSString *interpolationWithNoValue = L3InterpolateString(@"{xyz}", @{});
	l3_expect(interpolationWithNoValue).to.equal(@"xyz");
	NSString *interpolationWithMultipleValues = L3InterpolateString(@"one {two} three {four} five {six}", @{@"two": @2, @"four": @"quattro", @"six": @6.0});
	l3_expect(interpolationWithMultipleValues).to.equal(@"one 2 three quattro five 6");
})

static inline NSString *L3InterpolateString(NSString *format, NSDictionary *values) {
	NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"\\{([\\w]+)\\}" options:NSRegularExpressionCaseInsensitive error:NULL];
	NSMutableString *interpolated = [format mutableCopy];
	__block NSInteger offset = 0;
	[regularExpression enumerateMatchesInString:format options:NSMatchingWithTransparentBounds range:(NSRange){0, format.length} usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSString *placeholder = [regularExpression replacementStringForResult:result inString:format offset:0 template:@"$1"];
		NSRange range = result.range;
		range.location += offset;
		NSString *replacement = values[placeholder]? [values[placeholder] description] : placeholder;
		[interpolated replaceCharactersInRange:range withString:replacement];
		offset += ((NSInteger)replacement.length) - ((NSInteger)result.range.length);
	}];
	return [interpolated copy];
}

-(bool(^)(id object))equal {
	return ^bool(id object){
		NSString * const format = NSLocalizedString(@"equal {object}", @"Format string for predicates' imperative phrases. {object} is a placeholder for the object.");
		NSString *imperativePhrase = L3InterpolateString(format, @{@"object": object});
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
	NSString * const format = NSLocalizedString(@"{subjectSource} should {imperativePhrase}", @"Format string for expectations' assertive phrases. {subjectSource} is a placeholder for the source code of the subject. {imperativePhrase} is a placeholder for the predicate's imperative phrase.");
	return L3InterpolateString(format, @{@"subjectSource": self.subjectReference.subjectSource, @"imperativePhrase": self.nextPredicate.imperativePhrase});
}

-(NSString *)indicativePhrase {
	NSString * const format = NSLocalizedString(@"{subjectSource} ({subject}) does not {imperativePhrase}", @"Format string for expectations' indicative phrases (when failing). {subjectSource} is a placeholder for the subject's source code. {subject} is a placeholder for the subject. {imperativePhrase} is a placeholder for the predicate's imperative phrase.");
	return L3InterpolateString(format, @{@"subjectSource": self.subjectReference.subjectSource, @"subject": [self.subjectReference.subject description], @"imperativePhrase": self.nextPredicate.imperativePhrase});
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

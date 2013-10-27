#import "L3Expectation.h"
#import "L3SourceReference.h"
#import "L3Test.h"

#import "NSException+L3OCUnitCompatibility.h"

#import "Lagrangian.h"

@interface L3TestResult : NSObject <L3TestResult>

@property (nonatomic) id<L3SourceReference> subjectReference;

@property (nonatomic) NSString *hypothesisString;
@property (nonatomic) NSString *observationString;

@property (nonatomic) bool wasMet;
@property (nonatomic) NSException *exception;

@end


@class L3Predicate;
typedef bool (^L3PredicateBlock)(L3Predicate *predicate, id subject);

@interface L3Predicate : NSObject

@property (nonatomic, weak, readonly) id<L3Expectation> expectation;
@property (nonatomic, readonly) NSString *description;
@property (nonatomic, readonly) L3PredicateBlock block;

@property (nonatomic, strong) L3Predicate *next;

-(bool)testWithSubject:(id)subject;

@end

@implementation L3Predicate

-(instancetype)initWithExpectation:(id<L3Expectation>)expectation description:(NSString *)description block:(L3PredicateBlock)block {
	NSParameterAssert(block != nil);
	
	if ((self = [super init])) {
		_expectation = expectation;
		_description = [description copy];
		_block = [block copy];
	}
	return self;
}


-(bool)testWithSubject:(id)subject {
	return self.block(self, subject);
}

@end


@interface L3Expectation : NSObject <L3Expectation>

@property (nonatomic, weak) L3Test *test;

@property (nonatomic) L3Predicate *predicate;

@property (nonatomic, getter = isInverted) bool inverted;

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

l3_test(@selector(not), ^{
	l3_expect(@0).not.to.equal(@1);
})

-(id<L3Expectation>)not {
	self.inverted = YES;
	return self;
}


-(bool(^)(id object))equal {
	return ^bool(id object){
		self.predicate = [[L3Predicate alloc] initWithExpectation:self description:[NSString stringWithFormat:@"equal %@", object] block:^bool(L3Predicate *predicate, id subject) {
			return (subject == object) || [subject isEqual:object];
		}];
		return [self testExpectation];
	};
}


-(bool)testExpectation {
	bool wasMet = NO;
	NSException *unexpectedException = nil;
	@try {
		wasMet = [self.predicate testWithSubject:self.subjectReference.subject];
		wasMet = self.isInverted? !wasMet : wasMet;
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
	return [NSString stringWithFormat:@"%@ should%@ %@", self.subjectReference.subjectSource, self.isInverted? @" not" : @"", self.predicate];
}

-(NSString *)indicativePhrase {
	return [NSString stringWithFormat:@"%@ (%@) does%@ %@", self.subjectReference.subjectSource, self.subjectReference.subject, self.isInverted? @"" : @" not", self.predicate];
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
	result.subjectReference = L3SourceReferenceCreate(nil, exception.filename, exception.lineNumber.unsignedIntegerValue, nil, nil);
	result.hypothesisString = exception.reason;
	result.observationString = exception.reason;
	result.wasMet = NO;
	result.exception = nil;
	return result;
}

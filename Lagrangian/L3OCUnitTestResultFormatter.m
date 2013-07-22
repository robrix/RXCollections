//  L3OCUnitTestResultFormatter.m
//  Created by Rob Rix on 2012-11-11.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3OCUnitTestResultFormatter.h"
#import "L3StringInflections.h"
#import "L3TestResult.h"
#import "Lagrangian.h"

@interface L3OCUnitTestResultFormatter ()

-(NSString *)formatTestName:(NSString *)name;
-(NSString *)methodNameForTestResult:(L3TestResult *)testResult;

@end

@l3_suite_interface(L3OCUnitTestResultFormatter, "OCUnit-compatible event formatters") <L3TestResultFormatterDelegate>

@property L3OCUnitTestResultFormatter *formatter;
@property NSString *formattedString;
@property id<L3TestResult> result;
@property id<L3TestResult> compositeResult;

@end

@implementation L3OCUnitTestResultFormatter

@synthesize delegate = _delegate;

@l3_set_up {
	test.formatter = [L3OCUnitTestResultFormatter new];
	test.formatter.delegate = test;
	
	test.result = [L3TestResult testResultWithName:self.name file:self.file line:self.line startDate:[NSDate date]];
	test.compositeResult = [L3CompositeTestResult testResultWithName:self.name file:self.file line:self.line startDate:[NSDate date]];
}


#pragma mark L3TestResultBuilderDelegate

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResultDidStart:(L3TestResult *)result {
	NSString *formatted = nil;
	if (result.isComposite) {
		formatted = [NSString stringWithFormat:@"Test Suite '%@' started at %@\n", [self formatTestName:result.name], result.startDate];
	} else {
		formatted = [NSString stringWithFormat:@"Test Case '%@' started.", [self methodNameForTestResult:result]];
	}
	[self.delegate formatter:self didFormatResult:result asString:formatted];
}

@l3_test("do not format assertion successes") {
	[test.formatter testResultBuilder:nil testResult:test.result assertionDidSucceedWithSourceReference:l3_sourceReference(@"a", @"a", @"b")];
	l3_assert(test.formattedString, l3_is(nil));
}

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResult:(L3TestResult *)result assertionDidSucceedWithSourceReference:(L3SourceReference *)sourceReference {}

@l3_test("format assertion failures with their file, line, subject, subject source, and pattern source") {
	L3SourceReference *sourceReference = [L3SourceReference referenceWithFile:@"/foo/bar/file.m" line:42 subjectSource:@"x" subject:@"y" patternSource:@"src"];
	test.result.parent = test.compositeResult;
	[test.formatter testResultBuilder:nil testResult:test.result assertionDidFailWithSourceReference:sourceReference];
	l3_assert(test.formattedString, l3_equals([NSString stringWithFormat:@"/foo/bar/file.m:42: error: -[%1$@ %1$@] : 'x' was 'y' but should have matched 'src'", [test.formatter formatTestName:self.name]]));
}

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResult:(L3TestResult *)result assertionDidFailWithSourceReference:(L3SourceReference *)sourceReference {
	NSString *formatted = [NSString stringWithFormat:@"%@:%lu: error: %@ : %@",
						   sourceReference.file,
						   (unsigned long)sourceReference.line,
						   [self methodNameForTestResult:result],
						   sourceReference.reason];
	[self.delegate formatter:self didFormatResult:result asString:formatted];
}

@l3_test("format test suite end events with the sums of the test cases, failures, and durations they encompassed") {
	test.compositeResult.endDate = [NSDate dateWithTimeInterval:10 sinceDate:test.compositeResult.startDate];
	test.result.endDate = [NSDate dateWithTimeInterval:5 sinceDate:test.result.startDate];
	test.result.assertionCount = 3;
	test.result.assertionFailureCount = 3;
	test.result.parent = test.compositeResult;
	[test.compositeResult addTestResult:test.result];
	
	[test.formatter testResultBuilder:nil testResultDidFinish:test.compositeResult];
	l3_assert([test.formattedString rangeOfString:@"Executed 1 test, with 3 failures (0 unexpected) in 5.000 (10.000) seconds"].length > 0, l3_is(YES));
}

@l3_test("format test case end events with ‘passed’ for cases without any assertion failures") {
	[test.formatter testResultBuilder:nil testResultDidFinish:test.result];
	l3_assert([test.formattedString rangeOfString:@"passed"].length > 0, l3_is(YES));
}

@l3_test("format test case end events with ‘failed’ for cases with assertion failures") {
	test.result.assertionFailureCount = 1;
	[test.formatter testResultBuilder:nil testResultDidFinish:test.result];
	l3_assert([test.formattedString rangeOfString:@"failed"].length > 0, l3_is(YES));
}

@l3_test("format test case end events with the duration of the test") {
	test.result.endDate = [NSDate dateWithTimeInterval:5 sinceDate:test.result.startDate];
	[test.formatter testResultBuilder:nil testResultDidFinish:test.result];
	l3_assert([test.formattedString rangeOfString:@"(5.000 seconds)"].length > 0, @l3_is(YES));
}

@l3_test("format test case endings with a warning if the case performed no assertions (either directly or indirectly, via steps)") {
	[test.formatter testResultBuilder:nil testResultDidFinish:test.result];
	l3_assert([test.formattedString componentsSeparatedByString:@"\n"][0], l3_equals([NSString stringWithFormat:@"%@:%lu: note: -[%@ %@] : test case '%@' performed no assertions", self.file, (unsigned long)self.line, nil, [test.formatter formatTestName:self.name], self.name]));
}

-(void)testResultBuilder:(L3TestResultBuilder *)builder testResultDidFinish:(L3TestResult *)result {
	NSString *formatted = nil;
	if (result.isComposite) {
		formatted = [NSString stringWithFormat:@"Test Suite '%@' finished at %@.\nExecuted %@, with %@ (%lu unexpected) in %.3f (%.3f) seconds\n",
					 [self formatTestName:result.name],
					 result.endDate,
					 [L3StringInflections cardinalizeNoun:@"test" count:result.testCaseCount],
					 [L3StringInflections cardinalizeNoun:@"failure" count:result.assertionFailureCount],
					 (unsigned long)result.exceptionCount,
					 result.duration,
					 [result.endDate timeIntervalSinceDate:result.startDate]];
	} else {
		bool success = result.assertionFailureCount == 0;
		formatted = [NSString stringWithFormat:@"Test Case '%@' %@ (%.3f seconds).\n", [self methodNameForTestResult:result], success? @"passed" : @"failed", result.duration];
		if (result.assertionCount == 0)
		{
			NSString *note = [NSString stringWithFormat:@"%@:%lu: note: %@ : test case '%@' performed no assertions\n",
								 result.file,
								 (unsigned long)result.line,
								 [self methodNameForTestResult:result],
								 result.name];
			formatted = [note stringByAppendingString:formatted];
		}
	}
	[self.delegate formatter:self didFormatResult:result asString:formatted];
}


#pragma mark String formatting

@l3_test("format test names by replacing nonalphanumeric characters with underscores") {
	l3_assert([test.formatter formatTestName:@"foo bar's quux: herp?"], @"foo_bar_s_quux__herp_");
}

-(NSString *)formatTestName:(NSString *)name {
	NSMutableString *formatted = [name mutableCopy];
	NSRange range;
	NSMutableCharacterSet *disallowed = [NSMutableCharacterSet new];
	[disallowed formUnionWithCharacterSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
	[disallowed removeCharactersInString:@"_"];
	while ((range = [formatted rangeOfCharacterFromSet:disallowed]).length > 0) {
		[formatted replaceCharactersInRange:range withString:@"_"];
	}
	return formatted;
}

@l3_test("format faux method names from suite and test case names") {
	L3TestResult *suiteResult = [L3CompositeTestResult testResultWithName:@"suite of tests!" file:@"" __FILE__ line:__LINE__ startDate:[NSDate distantPast]];
	L3TestResult *caseResult = [L3TestResult testResultWithName:@"test of suites!" file:@"" __FILE__ line:__LINE__ startDate:[NSDate date]];
	[suiteResult addTestResult:caseResult];
	caseResult.parent = suiteResult;
	l3_assert([test.formatter methodNameForTestResult:caseResult], @"-[suite_of_tests_ test_of_suites_]");
}

-(NSString *)methodNameForTestResult:(L3TestResult *)result {
	return [NSString stringWithFormat:@"-[%@ %@]", [self formatTestName:result.parent.name], [self formatTestName:result.name]];
}

@end

@l3_suite_implementation (L3OCUnitTestResultFormatter)

-(void)formatter:(id<L3TestResultFormatter>)formatter didFormatResult:(L3TestResult *)result asString:(NSString *)string {
	self.formattedString = string;
}

@end

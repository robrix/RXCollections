#import "L3Expectation.h"
#import "L3SourceReference.h"
#import "L3Test.h"
#import "L3TestRunner.h"

#if !TARGET_OS_IPHONE
#if __has_feature(modules)
@import Cocoa;
#else
#import <Cocoa/Cocoa.h>
#endif
#endif

NSString * const L3TestRunnerRunTestsOnLaunchEnvironmentVariableName = @"L3_RUN_TESTS_ON_LAUNCH";
NSString * const L3TestRunnerSubjectEnvironmentVariableName = @"L3_TEST_RUNNER_SUBJECT";


@interface L3TestStatistics : NSObject
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;
@property (nonatomic) unsigned long testCount;
@property (nonatomic) unsigned long assertionFailureCount;
@property (nonatomic) unsigned long exceptionCount;
@property (nonatomic) NSTimeInterval duration;

-(void)addStatistics:(L3TestStatistics *)statistics;
@end

@interface L3TestRunner () <L3TestVisitor>

@property (nonatomic, readonly) NSOperationQueue *queue;

-(void)runAtLaunch;

@end

@implementation L3TestRunner

+(bool)shouldRunTestsAtLaunch {
	return [[NSProcessInfo processInfo].environment[L3TestRunnerRunTestsOnLaunchEnvironmentVariableName] boolValue];
}

+(bool)isRunningInApplication {
#if TARGET_OS_IPHONE
	return YES;
#else
	return
		([NSApplication class] != nil)
	&&	[[NSBundle mainBundle].bundlePath.pathExtension isEqualToString:@"app"];
#endif
}

+(NSString *)subjectPath {
	NSString *path = [NSProcessInfo processInfo].environment[L3TestRunnerSubjectEnvironmentVariableName];
	if (!path && self.isRunningInApplication) {
		path = [NSBundle mainBundle].bundlePath;
	}
	return path;
}


#pragma mark Constructors

L3_CONSTRUCTOR void L3TestRunnerLoader() {
	L3TestRunner *runner = [L3TestRunner new];
	
	if ([L3TestRunner shouldRunTestsAtLaunch]) {
		[runner runAtLaunch];
	}
}

-(instancetype)init {
	if ((self = [super init])) {
		_queue = [NSOperationQueue new];
		_queue.maxConcurrentOperationCount = 1;
	}
	return self;
}


#pragma mark Running

-(void)runAtLaunch {
	NSArray *tests = [[L3Test registeredSuites] allValues];
	if ([self.class subjectPath]) {
		L3Test *suite = [L3Test registeredSuiteForFile:[self.class subjectPath]];
		if (suite)
			tests = @[suite];
	}
#if TARGET_OS_IPHONE
#else
	if ([self.class isRunningInApplication]) {
		__block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationDidFinishLaunchingNotification object:nil queue:self.queue usingBlock:^(NSNotification *note) {
			
			[self enqueueTests:tests];
			
			[[NSNotificationCenter defaultCenter] removeObserver:observer name:NSApplicationDidFinishLaunchingNotification object:nil];
			
			[self.queue addOperationWithBlock:^{
				[[NSApplication sharedApplication] terminate:nil];
			}];
		}];
	} else {
		[self.queue addOperationWithBlock:^{
			[self enqueueTests:tests];
			
			[self.queue addOperationWithBlock:^{
				system("/usr/bin/osascript -e 'tell application \"Xcode\" to activate'");
				
				if ([self.class isRunningInApplication])
					[[NSApplication sharedApplication] terminate:nil];
				else
					exit(0);
			}];
		}];
	}
#endif
}

-(void)enqueueTests:(NSArray *)tests {
	for (L3Test *test in tests) {
		[self enqueueTest:test];
	}
}

-(void)enqueueTest:(L3Test *)test {
	NSParameterAssert(test != nil);
	[self.queue addOperationWithBlock:^{
		[test acceptVisitor:self parents:nil context:nil];
	}];
}

-(void)waitForTestsToComplete {
	[self.queue waitUntilAllOperationsAreFinished];
}


#pragma mark L3TestVisitor

-(void)write:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2) {
	va_list arguments;
	va_start(arguments, format);
	NSString *string = [[NSString alloc] initWithFormat:format arguments:arguments];
	fprintf(stdout, "%s", string.UTF8String);
	va_end(arguments);
}

-(NSString *)cardinalizeNoun:(NSString *)noun forCount:(NSInteger)count {
	return [NSString stringWithFormat:@"%li %@%@", count, noun, count == 1? @"" : @"s"];
}

-(NSString *)formatStringAsTestName:(NSString *)string {
	NSMutableString *mutable = [string mutableCopy];
	[[NSRegularExpression regularExpressionWithPattern:@"[^\\w]+" options:NSRegularExpressionCaseInsensitive error:NULL] replaceMatchesInString:mutable options:NSMatchingWithTransparentBounds range:(NSRange){0, mutable.length} withTemplate:@"_"];
	return [mutable copy];
}

-(NSString *)caseNameWithSuiteName:(NSString *)suiteName assertivePhrase:(NSString *)phrase {
	return [NSString stringWithFormat:@"-[%@ %@]", suiteName, [self formatStringAsTestName:phrase]];
}

-(id)visitTest:(L3Test *)test parents:(NSArray *)parents lazyChildren:(NSMutableArray *)lazyChildren context:(id)context {
	L3TestStatistics *statistics = [L3TestStatistics new];
	NSString *suiteName = [self formatStringAsTestName:[test.sourceReference.subject description]];
	[self write:@"Test Suite '%@' started at %@\n", suiteName, statistics.startDate];
	[self write:@"\n"];
	
	// fixme: can failures happen in test steps?
//	[test runSteps];
	
	[test run:^(id<L3Expectation> expectation, bool wasMet) {
		NSDate *testCaseStart = [NSDate date];
		statistics.testCount++;
		NSString *caseName = [self caseNameWithSuiteName:suiteName assertivePhrase:expectation.assertivePhrase];
		[self write:@"Test Case '%@' started.\n", caseName];
		if (!wasMet) {
			id<L3SourceReference> reference = expectation.subjectReference;
			[self write:@"%@:%lu: error: %@ : %@\n", reference.file, (unsigned long)reference.line, caseName, expectation.indicativePhrase];
			
			statistics.assertionFailureCount++;
			if (expectation.exception != nil)
				statistics.exceptionCount++;
		}
		NSTimeInterval interval = -[testCaseStart timeIntervalSinceNow];
		statistics.duration += interval;
		[self write:@"Test Case '%@' %@ (%.3f seconds).\n", caseName, wasMet? @"passed" : @"failed", interval];
		[self write:@"\n"];
	}];
	
	for (id(^lazyChild)() in lazyChildren) {
		[statistics addStatistics:lazyChild()];
	}
	
	statistics.endDate = [NSDate date];
	
	[self write:@"Test Suite '%@' finished at %@.\n", suiteName, statistics.endDate];
	[self write:@"Executed %@, with %@ (%lu unexpected) in %.3f (%.3f) seconds.\n", [self cardinalizeNoun:@"test" forCount:statistics.testCount], [self cardinalizeNoun:@"failure" forCount:statistics.assertionFailureCount], statistics.exceptionCount, statistics.duration, [statistics.endDate timeIntervalSinceDate:statistics.startDate]];
	[self write:@"\n"];
	
	return statistics;
}

@end

@implementation L3TestStatistics

-(instancetype)init {
	if ((self = [super init])) {
		_startDate = [NSDate date];
	}
	return self;
}

-(void)addStatistics:(L3TestStatistics *)statistics {
	self.testCount += statistics.testCount;
	self.assertionFailureCount += statistics.assertionFailureCount;
	self.exceptionCount += statistics.exceptionCount;
	self.duration += statistics.duration;
}

@end

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
NSString * const L3TestRunnerSuitePredicateEnvironmentVariableName = @"L3_SUITE_PREDICATE";


@interface L3TestRunner () <L3TestVisitor>

@property (nonatomic, readonly) NSOperationQueue *queue;

@property (nonatomic, readonly) NSMutableArray *mutableTests;

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

+(NSPredicate *)defaultPredicate {
	NSString *environmentPredicateFormat = [NSProcessInfo processInfo].environment[L3TestRunnerSuitePredicateEnvironmentVariableName];
	NSPredicate *applicationPredicate = [NSPredicate predicateWithFormat:@"(imagePath = NULL) || (imagePath CONTAINS[cd] %@)", [NSBundle mainBundle].bundlePath.lastPathComponent];
	NSPredicate *predicate = (environmentPredicateFormat? [NSPredicate predicateWithFormat:environmentPredicateFormat] : nil);
	return predicate?
		predicate
	:	(self.isRunningInApplication? applicationPredicate : nil);
}


#pragma mark Constructors

+(instancetype)runner {
	static L3TestRunner *runner = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		runner = [self new];
	});
	return runner;
}

L3_CONSTRUCTOR void L3TestRunnerLoader() {
	L3TestRunner *runner = [L3TestRunner runner];
	
	if ([L3TestRunner shouldRunTestsAtLaunch]) {
		[runner runAtLaunch];
	}
}

-(instancetype)init {
	if ((self = [super init])) {
		_mutableTests = [NSMutableArray new];
		
		_queue = [NSOperationQueue new];
		_queue.maxConcurrentOperationCount = 1;
		
		_testPredicate = [self.class defaultPredicate];
	}
	return self;
}


#pragma mark Running

-(void)runAtLaunch {
#if TARGET_OS_IPHONE
#else
	if ([self.class isRunningInApplication]) {
		__block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationDidFinishLaunchingNotification object:nil queue:self.queue usingBlock:^(NSNotification *note) {
			
			[self runTests];
			
			[[NSNotificationCenter defaultCenter] removeObserver:observer name:NSApplicationDidFinishLaunchingNotification object:nil];
			
			[self.queue addOperationWithBlock:^{
				[[NSApplication sharedApplication] terminate:nil];
			}];
		}];
	} else {
		[self.queue addOperationWithBlock:^{
			[self runTests];
			
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

-(void)runTests {
	for (L3Test *test in self.tests) {
		[self runTest:test];
	}
}

-(void)waitForTestsToComplete {
	[self.queue waitUntilAllOperationsAreFinished];
}

-(void)runTest:(L3Test *)test {
	NSParameterAssert(test != nil);
	
	[test acceptVisitor:self parents:nil context:nil];
}


-(NSArray *)tests {
	return self.mutableTests;
}

-(void)addTest:(L3Test *)test {
	[self.mutableTests addObject:test];
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
	NSString *suiteName = [test.sourceReference.file.lastPathComponent stringByDeletingPathExtension];
	NSDate *testSuiteStart = [NSDate date];
	[self write:@"Test Suite '%@' started at %@\n", suiteName, testSuiteStart];
	[self write:@"\n"];
	
	// fixme: can failures happen in test steps?
//	[test runSteps];
	
	__block unsigned long testCaseCount = 0;
	__block unsigned long assertionFailureCount = 0;
	__block unsigned long exceptionCount = 0;
	__block NSTimeInterval duration = 0;
	[test run:^(id<L3Expectation> expectation, bool wasMet) {
		NSDate *testCaseStart = [NSDate date];
		testCaseCount++;
		NSString *caseName = [self caseNameWithSuiteName:suiteName assertivePhrase:expectation.assertivePhrase];
		[self write:@"Test Case '%@' started.\n", caseName];
		if (wasMet) {
			
		} else {
			id<L3SourceReference> reference = expectation.subjectReference;
			[self write:@"%@:%lu: error: %@ : %@\n", reference.file, (unsigned long)reference.line, caseName, expectation.indicativePhrase];
			
			assertionFailureCount++;
			if (expectation.exception != nil)
				exceptionCount++;
		}
		NSTimeInterval interval = -[testCaseStart timeIntervalSinceNow];
		duration += interval;
		[self write:@"Test Case '%@' %@ (%.3f seconds).\n", caseName, wasMet? @"passed" : @"failed", interval];
		[self write:@"\n"];
	}];
	
	for (id(^lazyChild)() in lazyChildren) {
		lazyChild();
	}
	
	[self write:@"Test Suite '%@' finished at %@.\n", suiteName, [NSDate date]];
	[self write:@"Executed %@, with %@ (%lu unexpected) in %.3f (%.3f) seconds.\n", [self cardinalizeNoun:@"test" forCount:testCaseCount], [self cardinalizeNoun:@"failure" forCount:assertionFailureCount], exceptionCount, duration, -[testSuiteStart timeIntervalSinceNow]];
	[self write:@"\n"];
	
	return nil;
}

@end

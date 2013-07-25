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

-(void)runAtLaunch;

@end

@implementation L3TestRunner {
	NSMutableArray *_tests;
	NSMutableDictionary *_testsByName;
}

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
		_tests = [NSMutableArray new];
		_testsByName = [NSMutableDictionary new];
		
		_queue = [NSOperationQueue new];
		_queue.maxConcurrentOperationCount = 1;
		
		_testSuitePredicate = [self.class defaultPredicate];
	}
	return self;
}


#pragma mark Running

-(void)runAtLaunch {
#if TARGET_OS_IPHONE
#else
	if ([self.class isRunningInApplication]) {
		__block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationDidFinishLaunchingNotification object:nil queue:self.queue usingBlock:^(NSNotification *note) {
			
			[self run];
			
			[[NSNotificationCenter defaultCenter] removeObserver:observer name:NSApplicationDidFinishLaunchingNotification object:nil];
			
			[self.queue addOperationWithBlock:^{
				[[NSApplication sharedApplication] terminate:nil];
			}];
		}];
	} else {
		[self.queue addOperationWithBlock:^{
			[self run];
			
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

-(void)run {
//	[self runTest:self.test];
}

-(void)waitForTestsToComplete {
	[self.queue waitUntilAllOperationsAreFinished];
}

-(void)runTest:(L3Test *)test {
	NSParameterAssert(test != nil);
	
	[test acceptVisitor:self parents:nil context:nil];
}


#pragma mark L3TestVisitor

-(id)visitTest:(L3Test *)test parents:(NSArray *)parents children:(NSMutableArray *)children context:(id)context {
	
	return nil;
}

@end

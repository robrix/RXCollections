#import <Cocoa/Cocoa.h>
#import <dlfcn.h>
#import <stdio.h>
#import <stdlib.h>
#import <sys/sysctl.h>
#import "L3TRDynamicLibrary.h"

static void L3TRLogString(FILE *file, NSString *string) {
	fprintf(file, "%s", [string UTF8String]);
	fflush(stderr);
}

static __attribute__((noreturn)) void L3TRFailWithError(NSError *error) {
	L3TRLogString(stderr, @"lagrangian: fatal error: ");
	L3TRLogString(stderr, error.localizedDescription);
	L3TRLogString(stderr, @"\n");
	exit(EXIT_FAILURE);
}

static NSString *L3TRPathListByAddingPath(NSString *list, NSString *path) {
	return list?
		[list stringByAppendingFormat:@":%@", path]
	:	path;
}

static NSString * const L3TRLagrangianFrameworkPathArgumentName = @"lagrangian-framework-path";

static NSString * const L3TRDynamicLibraryPathEnvironmentVariableName = @"DYLD_LIBRARY_PATH";

#define L3TRTry(x) \
	(^{ \
		NSError *error = nil; \
		__typeof__(x) _result = (x); \
		if (!_result) \
			L3TRFailWithError(error); \
		return _result; \
	}())

static inline pid_t parentProcessOfProcess(pid_t process) {
	pid_t parentIdentifier = 0;
	struct kinfo_proc info;
	size_t length = sizeof(struct kinfo_proc);
	int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, process };
	if (sysctl(mib, 4, &info, &length, NULL, 0) == 0) {
		parentIdentifier = info.kp_eproc.e_ppid;
	}
	return parentIdentifier;
}

static inline bool processIsAncestorOfProcess(pid_t maybeAncestor, pid_t process) {
	bool isAncestor = NO;
	if (maybeAncestor > 0) {
		pid_t parent = parentProcessOfProcess(process);
		isAncestor =
			(maybeAncestor == parent)
		||	processIsAncestorOfProcess(maybeAncestor, parent);
	}
	return isAncestor;
}

@protocol L3Test <NSObject>
+(NSDictionary *)registeredSuites;
+(id<L3Test>)registeredSuiteForFile:(NSString *)file;
@end

@protocol L3TestRunner <NSObject>
+(BOOL)shouldRunTestsAtLaunch;
-(void)enqueueTest:(id<L3Test>)test;
-(BOOL)waitForTestsToComplete;
@end

static NSString * const L3TestRunnerRunTestsOnLaunchEnvironmentVariableName = @"L3_RUN_TESTS_ON_LAUNCH";
static NSString * const L3TestRunnerSubjectEnvironmentVariableName = @"L3_TEST_RUNNER_SUBJECT";

int main(int argc, const char *argv[]) {
	int result = EXIT_SUCCESS;
	@autoreleasepool {
		do {
			if ([NSClassFromString(@"L3TestRunner") shouldRunTestsAtLaunch]) { \
				dispatch_main(); \
			}
		} while(0);
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSProcessInfo *processInfo = [NSProcessInfo processInfo];
		
		[defaults registerDefaults:@{
		 L3TRLagrangianFrameworkPathArgumentName: [[processInfo.arguments[0] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Lagrangian.framework"]
		 }];
		
		if (!NSClassFromString(@"L3TestRunner")) {
			NSBundle *frameworkBundle = [NSBundle bundleWithPath:[defaults stringForKey:L3TRLagrangianFrameworkPathArgumentName]];
			L3TRTry([frameworkBundle loadAndReturnError:&error]);
		}
		
		NSString *frameworkPath = [defaults stringForKey:@"framework"];
		NSString *libraryPath = [defaults stringForKey:@"library"];
		NSString *command = [defaults stringForKey:@"command"];
		
		// fixme: abstract these into classes or something
		if (frameworkPath) {
			NSBundle *frameworkBundle = [NSBundle bundleWithPath:frameworkPath];
			L3TRTry([frameworkBundle loadAndReturnError:&error]);
			
			id<L3TestRunner> runner = [NSClassFromString(@"L3TestRunner") new];
			
			for (NSString *path in [NSClassFromString(@"L3Test") registeredSuites]) {
				if ([path hasPrefix:frameworkPath]) {
					[runner enqueueTest:[NSClassFromString(@"L3Test") registeredSuites][path]];
				}
			}
			
			result = [runner waitForTestsToComplete]?
				EXIT_SUCCESS
			:	EXIT_FAILURE;
		} else if (libraryPath) {
			L3TRTry([L3TRDynamicLibrary openLibraryAtPath:libraryPath error:&error]);
			
			id<L3TestRunner> runner = [NSClassFromString(@"L3TestRunner") new];
			
			id<L3Test> test = [NSClassFromString(@"L3Test") registeredSuiteForFile:libraryPath];
			if (test)
				[runner enqueueTest:test];
			
			result = [runner waitForTestsToComplete]?
				EXIT_SUCCESS
			:	EXIT_FAILURE;
		} else if (command) {
			NSTask *task = [NSTask new];
			
			task.launchPath = command; // fixme: this should probably include args or something
			// fixme: should know something about the calling environment
			
			NSMutableDictionary *environment = [processInfo.environment mutableCopy];
			
			environment[L3TRDynamicLibraryPathEnvironmentVariableName] = L3TRPathListByAddingPath(environment[L3TRDynamicLibraryPathEnvironmentVariableName], [[[NSUserDefaults standardUserDefaults] stringForKey:L3TRLagrangianFrameworkPathArgumentName] stringByDeletingLastPathComponent]);
			if (L3TestRunnerRunTestsOnLaunchEnvironmentVariableName != nil)
				environment[L3TestRunnerRunTestsOnLaunchEnvironmentVariableName] = @"YES";
			if (L3TestRunnerSubjectEnvironmentVariableName != nil)
				environment[L3TestRunnerSubjectEnvironmentVariableName] = command;
			
			task.environment = environment;
			
			[task launch];
			[task waitUntilExit];
			return [task terminationStatus] == EXIT_SUCCESS?
				EXIT_SUCCESS
			:	EXIT_FAILURE;
		}
		
		for (NSRunningApplication *xcode in [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.dt.Xcode"]) {
			if (processIsAncestorOfProcess(xcode.processIdentifier, getpid())) {
				[xcode activateWithOptions:NSApplicationActivateIgnoringOtherApps];
				break;
			}
		}
	}
	return result;
}

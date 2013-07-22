//  lagrangian-tool.m
//  Created by Rob Rix on 2012-11-07.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <stdio.h>
#import <stdlib.h>

#import "L3TRDynamicLibrary.h"

#import "Lagrangian.h"

@l3_suite("lagrangian");

@l3_test("runs tests in dynamic libraries") {
	// give it a library
	// assert that it was loaded
	
	// give it a library
	// assert that the library’s tests were run
	
	NSLog(@"running a test: %@", self.name);
}

@l3_test("runs tests in applications") {
	NSLog(@"running a test: %@", self.name);
}

static void L3TRLogString(FILE *file, NSString *string) {
	fprintf(file, "%s", [string UTF8String]);
	fflush(stderr);
}

static void L3TRFailWithError(NSError *error) {
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

NSString * const L3TRLagrangianFrameworkPathArgumentName = @"lagrangian-framework-path";

NSString * const L3TRDynamicLibraryPathEnvironmentVariableName = @"DYLD_LIBRARY_PATH";

#define L3TRTry(x) \
	(^{ \
		NSError *error = nil; \
		__typeof__(x) _result = (x); \
		if (!_result) \
			L3TRFailWithError(error); \
		return _result; \
	}())

int main(int argc, const char *argv[]) {
	int result = EXIT_SUCCESS;
	@autoreleasepool {
		l3_main(argc, argv);
		
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
		
		if (frameworkPath) {
			NSBundle *frameworkBundle = [NSBundle bundleWithPath:frameworkPath];
			L3TRTry([frameworkBundle loadAndReturnError:&error]);
			
			L3TestRunner *runner = [NSClassFromString(@"L3TestRunner") new];
			
			runner.testSuitePredicate = [NSPredicate predicateWithFormat:@"(imagePath = NULL) || (imagePath CONTAINS[cd] %@)", frameworkPath.lastPathComponent];
			
			[runner run];
			
			[runner waitForTestsToComplete];
		} else if (libraryPath) {
			L3TRTry([L3TRDynamicLibrary openLibraryAtPath:libraryPath error:&error]);
			
			L3TestRunner *runner = [NSClassFromString(@"L3TestRunner") new];
			
			runner.testSuitePredicate = [NSPredicate predicateWithFormat:@"(imagePath = NULL) || (imagePath ENDSWITH[cd] %@)", libraryPath.lastPathComponent];
			
			[runner run];
			
			[runner waitForTestsToComplete];
		} else if (command) {
			NSTask *task = [NSTask new];
			
			task.launchPath = command; // fixme: this should probably include args or something
			
			NSMutableDictionary *environment = [processInfo.environment mutableCopy];
			
			environment[L3TRDynamicLibraryPathEnvironmentVariableName] = L3TRPathListByAddingPath(environment[L3TRDynamicLibraryPathEnvironmentVariableName], [NSFileManager defaultManager].currentDirectoryPath);
			environment[@"L3_RUN_TESTS_ON_LAUNCH"] = @"YES";
			// fixme: there’s no possible way that passing the predicate format as the literal body of an environment variable could ever go wrong
			environment[@"L3_SUITE_PREDICATE"] = [NSString stringWithFormat:@"(imagePath = NULL) || (imagePath ENDSWITH[cd] '%@')", command.lastPathComponent];
			
			task.environment = environment;
			
			[task launch];
			[task waitUntilExit];
		}
	}
	return result;
}

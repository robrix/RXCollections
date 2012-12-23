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
	
	NSLog(@"running a test: %@", _case.name);
}

@l3_test("runs tests in applications") {
	NSLog(@"running a test: %@", _case.name);
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

NSString * const L3TRLagrangianLibraryPathArgumentName = @"lagrangian-library-path";

NSString * const L3TRDynamicLibraryPathEnvironmentVariableName = @"DYLD_LIBRARY_PATH";
NSString * const L3RunTestsOnLaunchEnvironmentVariableName = @"L3_RUN_TESTS_ON_LAUNCH";

extern char **environ;

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
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		[defaults registerDefaults:@{
		 L3TRLagrangianLibraryPathArgumentName: @"Lagrangian.dylib"
		 }];
		
		L3TRTry([L3TRDynamicLibrary openLibraryAtPath:[defaults stringForKey:L3TRLagrangianLibraryPathArgumentName] error:&error]);
		
		NSString *libraryPath = [defaults stringForKey:@"library"];
		NSString *command = [defaults stringForKey:@"command"];
		
		if (libraryPath) {
			L3TRTry([L3TRDynamicLibrary openLibraryAtPath:libraryPath error:&error]);
			
			L3TestRunner *runner = [NSClassFromString(@"L3TestRunner") new];
			
			[runner run];
			
			[runner waitForTestsToComplete];
		} else if (command) {
			NSDictionary *environment = [NSProcessInfo processInfo].environment;
			
			NSString *dynamicLibraryPath = L3TRPathListByAddingPath(environment[L3TRDynamicLibraryPathEnvironmentVariableName], [NSFileManager defaultManager].currentDirectoryPath);
			
			setenv(L3TRDynamicLibraryPathEnvironmentVariableName.UTF8String, dynamicLibraryPath.UTF8String, YES);
			setenv(L3RunTestsOnLaunchEnvironmentVariableName.UTF8String, "YES", YES);
			
			execve(command.fileSystemRepresentation, (char *const[]){ NULL }, environ);
		}
	}
	return result;
}

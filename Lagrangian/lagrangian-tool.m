//  lagrangian-tool.m
//  Created by Rob Rix on 2012-11-07.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <stdio.h>

#import "L3TRDynamicLibrary.h"

#import "Lagrangian.h"

@l3_suite("lagrangian");

@l3_test("runs tests in dynamic libraries") {
	// give it a library
	// assert that it was loaded
	
	// give it a library
	// assert that the library’s tests were run
}

@l3_test("runs tests in applications") {
	
}

void L3TRLogString(FILE *file, NSString *string) {
	fprintf(file, "%s", [string UTF8String]);
	fflush(stderr);
}

void L3TRFailWithError(NSError *error) {
	L3TRLogString(stderr, @"lagrangian: fatal error: ");
	L3TRLogString(stderr, error.localizedDescription);
	L3TRLogString(stderr, @"\n");
	exit(EXIT_FAILURE);
}

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
		
		L3TRTry([L3TRDynamicLibrary openLibraryAtPath:@"Lagrangian.dylib" error:&error]);
		
		NSString *libraryPath = [defaults stringForKey:@"library"];
		if (libraryPath) {
			L3TRDynamicLibrary *library = L3TRTry([L3TRDynamicLibrary openLibraryAtPath:libraryPath error:&error]);
			if (library) {
				L3TestRunner *runner = [NSClassFromString(@"L3TestRunner") new];
				
				[runner run];
				
				[runner waitForTestsToComplete];
			}
		}
	}
	return result;
}

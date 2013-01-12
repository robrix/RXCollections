//  L3TRDynamicLibrary.m
//  Created by Rob Rix on 2012-12-21.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TRDynamicLibrary.h"

#import <dlfcn.h>

@interface L3TRDynamicLibrary ()
@property (nonatomic, assign, readonly) void *handle;
@end

@implementation L3TRDynamicLibrary

+(NSError *)errorWithDYLDErrorString:(const char *)string {
	return [NSError errorWithDomain:@"com.antitypical.lagrangian" code:1 userInfo:@{
		  NSLocalizedDescriptionKey: [NSString stringWithUTF8String:string]
			}];
}

+(void *)validateDYLDPointer:(void *)pointer error:(NSError **)error {
	if (!pointer) {
		const char *errorMessage = dlerror();
		if (error)
			*error = [self errorWithDYLDErrorString:errorMessage];
	}
	return pointer;
}

+(instancetype)openLibraryAtPath:(NSString *)path error:(NSError **)error {
	L3TRDynamicLibrary *library = nil;
	void *handle = [self validateDYLDPointer:dlopen(path.fileSystemRepresentation, RTLD_NOW | RTLD_LOCAL) error:error];
	if (handle) {
		library = [self new];
		library->_path = [path copy];
		library->_handle = handle;
	}
	return library;
}

-(void)dealloc {
	dlclose(_handle);
}


-(void *)loadSymbolWithName:(NSString *)symbolName error:(NSError **)error {
	return [self.class validateDYLDPointer:dlsym(self.handle, symbolName.UTF8String) error:error];
}

@end

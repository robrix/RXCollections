#import "L3TRDynamicLibrary.h"
#import <dlfcn.h>

@interface L3TRDynamicLibrary ()
@property (readonly) void *handle;
@end

@implementation L3TRDynamicLibrary

+(NSError *)errorWithDYLDErrorString:(const char *)string {
	return [NSError errorWithDomain:@"com.antitypical.lagrangian" code:1 userInfo:@{
		  NSLocalizedDescriptionKey: [NSString stringWithUTF8String:string]
			}];
}

+(void *)validateDYLDPointer:(void *)pointer error:(NSError * __autoreleasing *)error {
	if (!pointer) {
		const char *errorMessage = dlerror();
		if (error)
			*error = [self errorWithDYLDErrorString:errorMessage];
	}
	return pointer;
}

+(instancetype)openLibraryAtPath:(NSString *)path error:(NSError * __autoreleasing *)error {
	L3TRDynamicLibrary *library = nil;
	void *handle = [self validateDYLDPointer:dlopen(path.fileSystemRepresentation, RTLD_NOW | RTLD_LOCAL) error:error];
	if (handle) {
		library = [[self alloc] initWithPath:path handle:handle];
	}
	return library;
}

-(instancetype)initWithPath:(NSString *)path handle:(void *)handle {
	if ((self = [super init])) {
		_path = [path copy];
		_handle = handle;
	}
	return self;
}

-(void)dealloc {
	dlclose(_handle);
}


-(void *)loadSymbolWithName:(NSString *)symbolName error:(NSError * __autoreleasing *)error {
	return [self.class validateDYLDPointer:dlsym(self.handle, symbolName.UTF8String) error:error];
}

@end

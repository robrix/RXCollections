#import <Foundation/Foundation.h>

@interface L3TRDynamicLibrary : NSObject

+(instancetype)openLibraryAtPath:(NSString *)path error:(NSError * __autoreleasing *)error;

@property (readonly) NSString *path;

-(void *)loadSymbolWithName:(NSString *)symbolName error:(NSError * __autoreleasing *)error;

@end

//  L3TRDynamicLibrary.h
//  Created by Rob Rix on 2012-12-21.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

@interface L3TRDynamicLibrary : NSObject

+(instancetype)openLibraryAtPath:(NSString *)path error:(NSError * __autoreleasing *)error;

@property (nonatomic, readonly) NSString *path;

-(void *)loadSymbolWithName:(NSString *)symbolName error:(NSError * __autoreleasing *)error;

@end

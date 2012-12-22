//  L3TRDynamicLibrary.h
//  Created by Rob Rix on 2012-12-21.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import <Foundation/Foundation.h>

@interface L3TRDynamicLibrary : NSObject

+(instancetype)openLibraryAtPath:(NSString *)path error:(NSError **)error;

@property (nonatomic, copy, readonly) NSString *path;

-(void *)loadSymbolWithName:(NSString *)symbolName error:(NSError **)error;

@end

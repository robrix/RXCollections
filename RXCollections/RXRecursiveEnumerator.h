//
//  RXRecursiveEnumerator.h
//  View Streamer
//
//  Created by Rob Rix on 2013-01-11.
//  Copyright (c) 2013 Rob Rix. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RXRecursiveEnumerator : NSObject <NSFastEnumeration>

+(instancetype)enumeratorWithTarget:(id)target keyPath:(NSString *)keyPath;

@property (nonatomic, strong, readonly) id target;
@property (nonatomic, copy, readonly) NSString *keyPath;

@end

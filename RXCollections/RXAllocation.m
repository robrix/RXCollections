//  RXAllocation.m
//  Created by Rob Rix on 7/21/2013.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "RXAllocation.h"

#import <objc/runtime.h>

#if __has_feature(objc_arc_)
#error This file cannot be compiled under ARC. Add -fno-objc-arc to the compilation flags for this file.
#endif

@implementation NSObject (RXAllocation)

+(instancetype)allocateWithExtraSize:(size_t)extraSize {
	return class_createInstance(self, extraSize);
}


-(void *)extraSpace {
	return object_getIndexedIvars(self);
}

@end

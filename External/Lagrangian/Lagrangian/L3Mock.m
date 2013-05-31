//  L3Mock.m
//  Created by Rob Rix on 2013-05-30.
//  Copyright (c) 2013 Rob Rix. All rights reserved.

#import "L3Mock.h"

#import <Lagrangian/Lagrangian.h>
#import <objc/runtime.h>

@l3_suite("L3Mock");

@interface L3Mock () <L3Mock>
@end

@implementation L3Mock

+(id)mockNamed:(NSString *)name initializer:(void(^)(id<L3Mock> mock))initializer {
	return [[self alloc] initWithName:name initializer:initializer];
}

+(NSString *)classNameForName:(NSString *)name {
	return [NSStringFromClass(self.class) stringByAppendingFormat:@"_%@", name];
}

-(instancetype)initWithName:(NSString *)name initializer:(void(^)(id<L3Mock> mock))initializer {
	if ((self = [super init])) {
		Class class = objc_getClass([self.class classNameForName:name].UTF8String);
		if (!class) {
			class = objc_allocateClassPair(object_getClass(self), [self.class classNameForName:name].UTF8String, 0);
			
			initializer(self);
			
			objc_registerClassPair(class);
		}
		object_setClass(self, class);
	}
	return self;
}


@l3_test("mocking creates a class at runtime and adds methods to it, which are then available on the instance") {
	L3Mock *mock = [L3Mock mockNamed:@"Mock" initializer:^(id<L3Mock> mock) {
		[mock addMethodWithSelector:@selector(description) types:L3TypeSignature(id, id, SEL) block:^{
			return @"test";
		}];
	}];
	l3_assert(mock.description, @"test");
}

-(void)addMethodWithSelector:(SEL)selector types:(const char *)types block:(id)block {
	IMP implementation = imp_implementationWithBlock(block);
	class_addMethod(self.class, selector, implementation, types);
}

@end


const char *L3ConstructTypeSignature(char type[], ...) {
	va_list types;
	va_start(types, type);
	NSMutableString *signature = [NSMutableString new];
	
	do {
		[signature appendFormat:@"%s", type];
	} while ((type = va_arg(types, char *)));
	
	va_end(types);
	return signature.UTF8String;
}

#import "L3Mock.h"

#import <Lagrangian/Lagrangian.h>
#if __has_feature(modules)
@import ObjectiveC.runtime;
#else
#import <objc/runtime.h>
#endif

@interface L3Mock () <L3Mock>

@property (nonatomic, readonly) Class customClass;

@end

@implementation L3Mock

+(instancetype)mockNamed:(NSString *)name initializer:(void(^)(id<L3Mock> mock))initializer {
	return [[self alloc] initWithName:name initializer:initializer];
}

+(NSString *)classNameForName:(NSString *)name {
	return [NSStringFromClass(self.class) stringByAppendingFormat:@"_%@", name];
}

-(instancetype)initWithName:(NSString *)name initializer:(void(^)(id<L3Mock> mock))initializer {
	if ((self = [super init])) {
		_customClass = objc_getClass([self.class classNameForName:name].UTF8String);
		if (!_customClass) {
			_customClass = objc_allocateClassPair(object_getClass(self), [self.class classNameForName:name].UTF8String, 0);
			
			initializer(self);
			
			objc_registerClassPair(_customClass);
		}
		object_setClass(self, _customClass);
	}
	return self;
}


l3_test(@selector(addMethodWithSelector:types:block:), ^{
	L3Mock *mock = [L3Mock mockNamed:@"Mock" initializer:^(id<L3Mock> mock) {
		[mock addMethodWithSelector:@selector(description) types:L3TypeSignature(id, id, SEL) block:^{
			return @"test";
		}];
	}];
	l3_expect(mock.description).to.equal(@"test");
})

-(void)addMethodWithSelector:(SEL)selector types:(const char *)types block:(id)block {
	IMP implementation = imp_implementationWithBlock(block);
	class_addMethod(self.customClass, selector, implementation, types);
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

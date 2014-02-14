#import "Lagrangian.h"
#import "L3Block.h"
#import "L3Mock.h"

#if __has_feature(modules)
@import ObjectiveC.runtime;
#else
#import <objc/runtime.h>
#endif

@interface L3MockBuilder : NSObject <L3MockBuilder>

+(Class)classWithName:(const char *)className initializer:(L3MockInitializer)initializer;

@property (nonatomic, readonly) Class targetClass;

@end

@implementation L3Mock

+(NSString *)uniqueMockClassName {
	NSUUID *UUID = [NSUUID UUID];
	return [@"L3Mock_" stringByAppendingString:[[UUID UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@"_"]];
}

+(id)mockWithInitializer:(L3MockInitializer)initializer {
	return [self mockNamed:[self uniqueMockClassName] initializer:initializer];
}

+(id)mockNamed:(NSString *)name initializer:(L3MockInitializer)initializer {
	return [[[L3MockBuilder classWithName:[self classNameForName:name].UTF8String initializer:initializer] alloc] init];
}

+(NSString *)classNameForName:(NSString *)name {
	return [NSStringFromClass(self.class) stringByAppendingFormat:@"_%@", name];
}

@end

@implementation L3MockBuilder

+(Class)classWithName:(const char *)className initializer:(L3MockInitializer)initializer {
	Class class = objc_getClass(className);
	if (!class) {
		class = objc_allocateClassPair([L3Mock class], className, 0);
		
		initializer([[self alloc] initWithClass:class]);
		
		objc_registerClassPair(class);
	}
	return class;
}

-(instancetype)initWithClass:(Class)class {
	if ((self = [super init])) {
		_targetClass = class;
	}
	return self;
}


l3_test(@selector(addMethodWithSelector:block:), ^{
	__block NSString *test;
	L3Mock *mock = [L3Mock mockWithInitializer:^(id<L3MockBuilder> mock) {
		[mock addMethodWithSelector:@selector(description) block:^{
			return test;
		}];
		
		[mock addMethodWithSelector:@selector(isEqual:) block:^BOOL (L3Mock *self, id other) {
			NSLog(@"self: %@ other: %@", self, other);
			return [[other description] isEqualToString:self.description];
		}];
	}];
	l3_expect(mock.description).to.equal(nil);
	
	test = @"test";
	l3_expect(mock.description).to.equal(@"test");
	
	l3_expect(mock).to.equal(@"test");
})

-(void)addMethodWithSelector:(SEL)selector block:(id)block {
	[self addMethodWithSelector:selector types:L3BlockGetSignature(block) block:block];
}

l3_test(@selector(addMethodWithSelector:types:block:), ^{
	L3Mock *mock = [L3Mock mockWithInitializer:^(id<L3MockBuilder> mock) {
		[mock addMethodWithSelector:@selector(description) types:L3TypeSignature(id, id, SEL) block:^{
			return @"test";
		}];
	}];
	l3_expect(mock.description).to.equal(@"test");
})

-(void)addMethodWithSelector:(SEL)selector types:(const char *)types block:(id)block {
	IMP implementation = imp_implementationWithBlock(block);
	class_addMethod(self.targetClass, selector, implementation, types);
}

-(void)addProtocol:(Protocol *)protocol {
	class_addProtocol(self.targetClass, protocol);
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

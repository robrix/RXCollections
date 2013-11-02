#import "L3TestState.h"

#import "Lagrangian.h"

#if __has_feature(modules)
@import ObjectiveC.runtime;
#else
#import <objc/runtime.h>
#endif

l3_setup((NSNumber *flag), ^{
	NSLog(@"about to set the flag");
	[self self];
	self.state.flag = @YES;
	[self self];
})

l3_test("l3_setup", ^{
	l3_expect(self.state.flag).to.equal(@YES);
})

@protocol L3TestStateProtocolTest <NSObject>

@property (nonatomic) NSString *string;
@property (nonatomic) CGFloat floatValue;
@property (nonatomic) NSFastEnumerationState fastEnumerationState;

@end


@interface L3TestState ()

@property (nonatomic, readonly) NSMutableDictionary *propertyNamesBySelectorString;

@end

@implementation L3TestState

static inline NSString *L3TestStateGetterForProperty(objc_property_t property) {
	const char *getterValue = property_copyAttributeValue(property, "G");
	NSString *getter = getterValue? @(getterValue) : nil;
	if (!getter)
		getter = @(property_getName(property));
	return getter;
}

static inline NSString *L3TestStateSetterForProperty(objc_property_t property) {
	const char *setterValue = property_copyAttributeValue(property, "S");
	NSString *setter = setterValue? @(setterValue) : nil;
	if (!setter) {
		NSString *propertyName = @(property_getName(property));
		setter = [NSString stringWithFormat:@"set%@%@:", [[propertyName substringToIndex:1] uppercaseString], [propertyName substringFromIndex:1]];
	}
	return setter;
}

+(instancetype)stateWithProtocol:(Protocol *)stateProtocol setUpBlock:(L3TestStateBlock)setUpBlock {
	return [[self alloc] initWithProtocol:stateProtocol setUpBlock:setUpBlock];
}

-(instancetype)initWithProtocol:(Protocol *)stateProtocol setUpBlock:(L3TestStateBlock)setUpBlock {
	NSParameterAssert(stateProtocol != nil);
	
	if ((self = [super init])) {
		_stateProtocol = stateProtocol;
		_properties = [NSMutableDictionary new];
		
		_propertyNamesBySelectorString = [NSMutableDictionary new];
		
		_setUpBlock = [setUpBlock copy];
		
		unsigned int propertyCount = 0;
		objc_property_t *properties = protocol_copyPropertyList(self.stateProtocol, &propertyCount);
		
		for (NSUInteger i = 0; i < propertyCount; i++) {
			_propertyNamesBySelectorString[L3TestStateGetterForProperty(properties[i])] =
			_propertyNamesBySelectorString[L3TestStateSetterForProperty(properties[i])] =
				@(property_getName(properties[i]));
		}
		
		free(properties);
	}
	return self;
}


#pragma mark Lifespan

-(void)setUpWithTest:(L3Test *)test {
	if (self.setUpBlock)
		self.setUpBlock(test);
}


#pragma mark Method signatures

enum L3ProtocolOptions : NSUInteger {
	L3ProtocolMethodOptionRequired = 1 << 0,
	L3ProtocolMethodOptionInstance = 1 << 1,
	
	L3ProtocolMethodOptionOptional = 0,
	L3ProtocolMethodOptionClass = 0,
};

-(const char *)typesForMethodInProtocolWithSelector:(SEL)selector options:(enum L3ProtocolOptions)options {
	return protocol_getMethodDescription(self.stateProtocol, selector, options & L3ProtocolMethodOptionRequired, options & L3ProtocolMethodOptionInstance).types;
}

l3_test(@selector(typesForMethodInProtocolWithSelector:), ^{
	L3TestState *state = [L3TestState stateWithProtocol:@protocol(L3TestStateProtocolTest) setUpBlock:nil];
	
	l3_expect([state typesForMethodInProtocolWithSelector:@selector(string)]).to.equal(@"@16@0:8");
	l3_expect([state typesForMethodInProtocolWithSelector:@selector(setString:)]).to.equal(@"v24@0:8@16");
})

-(const char *)typesForMethodInProtocolWithSelector:(SEL)selector {
	const char *types = NULL;
	NSArray *allOptions = @[
		@(L3ProtocolMethodOptionOptional | L3ProtocolMethodOptionClass),
		@(L3ProtocolMethodOptionRequired | L3ProtocolMethodOptionClass),
		@(L3ProtocolMethodOptionOptional | L3ProtocolMethodOptionInstance),
		@(L3ProtocolMethodOptionRequired | L3ProtocolMethodOptionInstance),
	];
	for (NSNumber *options in allOptions) {
		types = [self typesForMethodInProtocolWithSelector:selector options:options.unsignedIntegerValue];
		if (types)
			break;
	}
	return types;
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
	NSMethodSignature *signature = [super methodSignatureForSelector:selector];
	if (!signature)
		signature = [NSMethodSignature signatureWithObjCTypes:[self typesForMethodInProtocolWithSelector:selector]];
	return signature;
}


#pragma mark Responding

-(BOOL)respondsToSelector:(SEL)selector {
	return
		[super respondsToSelector:selector]
	||	[self typesForMethodInProtocolWithSelector:selector] != NULL;
}


#pragma mark Forwarding

l3_test(@selector(forwardInvocation:), ^{
	L3TestState<L3TestStateProtocolTest> *state = (L3TestState<L3TestStateProtocolTest> *)[L3TestState stateWithProtocol:@protocol(L3TestStateProtocolTest) setUpBlock:nil];
	
	l3_expect(state.string).to.equal(nil);
	@autoreleasepool {
		state.string = [NSString stringWithFormat:@"phrenolo%@y", @"g"];
	}
	l3_expect(state.string).to.equal(@"phrenology");
	
	l3_expect(state.floatValue).to.equal(@0.0);
	state.floatValue = M_PI;
	l3_expect(state.floatValue).to.equal(@M_PI);
	
	l3_expect(state.fastEnumerationState).to.equal([NSValue valueWithBytes:&(NSFastEnumerationState){0} objCType:@encode(NSFastEnumerationState)]);
	
	l3_expect(state.fastEnumerationState).to.equal([NSValue valueWithBytes:&(NSFastEnumerationState){0} objCType:@encode(NSFastEnumerationState)]);
})

-(void)forwardInvocation:(NSInvocation *)invocation {
	NSString *selectorString = NSStringFromSelector(invocation.selector);
	NSString *propertyName = self.propertyNamesBySelectorString[selectorString];
	
	if (L3TestStateSelectorStringIsSetter(selectorString)) {
		bool isObject = L3TestStateTypeStringRepresentsObject([invocation.methodSignature getArgumentTypeAtIndex:2]);
		intptr_t bytes[(invocation.methodSignature.frameLength - [self methodSignatureForSelector:@selector(description)].frameLength) / sizeof(intptr_t)];
		[invocation getArgument:bytes atIndex:2];
		self.properties[propertyName] = isObject?
			(__bridge id)*(void **)bytes
		:	[NSValue valueWithBytes:bytes objCType:[invocation.methodSignature getArgumentTypeAtIndex:2]];
	} else {
		bool isObject = L3TestStateTypeStringRepresentsObject(invocation.methodSignature.methodReturnType);
		id value = self.properties[propertyName];
		if (isObject) {
			[invocation setReturnValue:&value];
		} else {
			intptr_t bytes[invocation.methodSignature.methodReturnLength];
			if (value)
				[value getValue:&bytes];
			else
				memset(bytes, 0, sizeof bytes);
			[invocation setReturnValue:bytes];
		}
	}
}


#pragma mark Categorizing

l3_test(@selector(selectorStringIsSetter:), ^{
	l3_expect(L3TestStateSelectorStringIsSetter(@"setFoo:")).to.equal(@YES);
	l3_expect(L3TestStateSelectorStringIsSetter(@"setF:")).to.equal(@YES);
	
	l3_expect(L3TestStateSelectorStringIsSetter(@"set:")).to.equal(@NO);
	l3_expect(L3TestStateSelectorStringIsSetter(@"set")).to.equal(@NO);
	l3_expect(L3TestStateSelectorStringIsSetter(@"setfoo:")).to.equal(@NO);
	l3_expect(L3TestStateSelectorStringIsSetter(@"setFoo")).to.equal(@NO);
})

static inline bool L3TestStateSelectorStringIsSetter(NSString *selectorString) {
	NSRegularExpression *setterExpression = [NSRegularExpression regularExpressionWithPattern:@"^set[A-Z_][a-zA-Z_]*:$" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
	return [setterExpression numberOfMatchesInString:selectorString options:NSMatchingAnchored range:(NSRange){0, selectorString.length}];
}

static inline bool L3TestStateTypeStringRepresentsObject(const char *type) {
	return strncmp(type, @encode(id), 1) == 0;
}

@end


@interface L3TestStatePrototype ()

@property (nonatomic, readonly) Protocol *stateProtocol;
@property (nonatomic, readonly) L3TestStateBlock setUpBlock;

@end

@implementation L3TestStatePrototype

+(instancetype)statePrototypeWithProtocol:(Protocol *)stateProtocol setUpBlock:(L3TestStateBlock)setUpBlock {
	return [[self alloc] initWithProtocol:stateProtocol setUpBlock:setUpBlock];
}

-(instancetype)initWithProtocol:(Protocol *)stateProtocol setUpBlock:(L3TestStateBlock)setUpBlock {
	if ((self = [super init])) {
		_stateProtocol = stateProtocol;
		_setUpBlock = [setUpBlock copy];
	}
	return self;
}

-(L3TestState *)createState {
	return [[L3TestState alloc] initWithProtocol:self.stateProtocol setUpBlock:self.setUpBlock];
}

@end

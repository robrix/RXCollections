#import "L3Test.h"

#import "Lagrangian.h"

#if __has_feature(modules)
@import Darwin.POSIX.dlfcn;
#else
#import <dlfcn.h>
#endif

NSString * const L3ErrorDomain = @"com.antitypical.lagrangian";

NSString * const L3ExpectationErrorKey = @"L3ExpectationErrorKey";
NSString * const L3TestErrorKey = @"L3TestErrorKey";

@interface L3Test ()

@property (nonatomic, readonly) L3TestBlock block;

//@property (nonatomic, readonly) NSMutableArray *mutableSteps;
@property (nonatomic, readonly) NSMutableArray *mutableExpectations;
@property (nonatomic, readonly) NSMutableArray *mutableChildren;

@end

@implementation L3Test

+(NSMutableDictionary *)mutableRegisteredSuites {
	static NSMutableDictionary *suites = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		suites = [NSMutableDictionary new];
	});
	return suites;
}

+(NSDictionary *)registeredSuites {
	return self.mutableRegisteredSuites;
}

+(instancetype)suiteForFile:(NSString *)file initializer:(L3Test *(^)())block {
	L3Test *suite = self.mutableRegisteredSuites[file];
	if (!suite) {
		suite = block? block() : nil;
		if (suite) {
			self.mutableRegisteredSuites[file] = suite;
		}
	}
	return suite;
}

+(instancetype)registeredSuiteForFile:(NSString *)file {
	return self.mutableRegisteredSuites[file];
}

static inline NSString *L3PathForImageWithAddress(void(*address)(void)) {
	NSString *path = nil;
	Dl_info info = {0};
	if (dladdr((void *)address, &info)) {
		path = @(info.dli_fname);
	}
	return path;
}

+(instancetype)suiteForImageWithAddress:(void(*)(void))address {
	NSString *file = L3PathForImageWithAddress(address);
	return [self suiteForFile:file initializer:^L3Test *{
		return [[self alloc] initWithSourceReference:L3SourceReferenceCreate(@0, file, 0, nil, [file lastPathComponent]) block:nil];
	}];
}

+(instancetype)suiteForFile:(NSString *)file inImageForAddress:(void(*)(void))address {
	return [self suiteForFile:file initializer:^L3Test *{
		L3Test *suite = [[self alloc] initWithSourceReference:L3SourceReferenceCreate(@0, file, 0, nil, [[file lastPathComponent] stringByDeletingPathExtension]) block:nil];
		L3Test *imageSuite = [self suiteForImageWithAddress:address];
		[imageSuite addChild:suite];
		return suite;
	}];
}

-(instancetype)initWithSourceReference:(id<L3SourceReference>)sourceReference block:(L3TestBlock)block {
	if ((self = [super init])) {
		_sourceReference = sourceReference;
		
		_block = [block copy];
		
//		_mutableSteps = [NSMutableArray new];
		_mutableExpectations = [NSMutableArray new];
		_mutableChildren = [NSMutableArray new];
	}
	return self;
}


//-(NSArray *)steps {
//	return self.mutableSteps;
//}
//
//-(void)addStep:(L3TestBlock)block {
//	[self.mutableSteps addObject:block];
//}


-(NSArray *)expectations {
	return self.mutableExpectations;
}

-(void)addExpectation:(id<L3Expectation>)expectation {
	[self.mutableExpectations addObject:expectation];
}


-(NSArray *)children {
	return self.mutableChildren;
}

-(void)addChild:(L3Test *)test {
	[self.mutableChildren addObject:test];
}


//-(void)runSteps {
//	for (L3TestBlock step in self.steps) {
//		step();
//	}
//}

-(void)run:(L3TestExpectationBlock)callback {
	if (self.block)
		self.block(callback);
}


l3_test(@selector(addObject:), ^{
	NSMutableArray *array = [NSMutableArray new];
	[array addObject:@0];
	
	l3_expect(array.count).to.equal(@1);
	l3_expect(array.lastObject).to.equal(@0);
})


-(id)acceptVisitor:(id<L3TestVisitor>)visitor parents:(NSArray *)parents context:(id)context {
	NSMutableArray *lazyChildren = self.children.count? [NSMutableArray new] : nil;
	NSArray *childParents = parents?
		[parents arrayByAddingObject:self]
	:	@[self];
	for (L3Test *child in self.children) {
		[lazyChildren addObject:^{ return [child acceptVisitor:visitor parents:childParents context:context]; }];
	}
	return [visitor visitTest:self parents:parents lazyChildren:lazyChildren context:context];
}

@end

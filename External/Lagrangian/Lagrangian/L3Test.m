#import "L3Block.h"
#import "L3Test.h"
#import "Lagrangian.h"
#import <dlfcn.h>


NSString * const L3ErrorDomain = @"com.antitypical.lagrangian";

NSString * const L3ExpectationErrorKey = @"L3ExpectationErrorKey";
NSString * const L3TestErrorKey = @"L3TestErrorKey";

@interface L3Test ()

@property (nonatomic, readonly) L3TestBlock block;

@property (nonatomic, readonly) NSMutableArray *mutableExpectations;
@property (nonatomic, readonly) NSMutableArray *mutableChildren;

@property (nonatomic, copy) L3TestExpectationBlock expectationCallback;

@property (nonatomic) L3TestState *state;

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
		return [[self alloc] initWithSourceReference:L3SourceReferenceCreate(@0, file, 0, nil, file.lastPathComponent) block:nil];
	}];
}

+(instancetype)suiteForFile:(NSString *)file inImageForAddress:(void(*)(void))address {
	return [self suiteForFile:file initializer:^L3Test *{
		L3Test *suite = [[self alloc] initWithSourceReference:L3SourceReferenceCreate(@0, file, 0, nil, [file.lastPathComponent stringByDeletingPathExtension]) block:nil];
		L3Test *imageSuite = [self suiteForImageWithAddress:address];
		[imageSuite addChild:suite];
		return suite;
	}];
}

+(instancetype)testWithSourceReference:(id<L3SourceReference>)sourceReference block:(L3TestBlock)block {
	return [[self alloc] initWithSourceReference:sourceReference block:block];
}

-(instancetype)initWithSourceReference:(id<L3SourceReference>)sourceReference block:(L3TestBlock)block {
	if ((self = [super init])) {
		_sourceReference = sourceReference;
		
		_block = [block copy];
		
		_mutableExpectations = [NSMutableArray new];
		_mutableChildren = [NSMutableArray new];
	}
	return self;
}


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


-(void)setUp {
	self.state = [self.statePrototype createState];
	[self.state setUpWithTest:self];
}

-(void)tearDown {
	self.state = nil;
}

-(void)run:(L3TestExpectationBlock)expectationCallback {
	self.expectationCallback = expectationCallback;
	if (self.block)
		self.block();
}

-(void)expectation:(id<L3Expectation>)expectation producedResult:(id<L3TestResult>)result {
	if (self.expectationCallback)
		self.expectationCallback(expectation, result);
}

-(void)failWithException:(NSException *)exception {
	[self expectation:nil producedResult:L3TestResultCreateWithException(exception)];
}


l3_test(@selector(addObject:), ^{
	NSMutableArray *array = [NSMutableArray new];
	[array addObject:@0];
	
	l3_expect(array.count).to.equal(@1);
	l3_expect(array.lastObject).to.equal(@0);
})


#pragma mark L3TestVisitor

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


NSString *L3TestSymbolForFunction(L3FunctionTestSubject subject) {
	NSString *symbol;
	Dl_info info = {0};
	if (dladdr((void *)subject, &info)) {
		symbol = @(info.dli_sname);
	}
	return symbol;
}

L3BlockFunction L3TestFunctionForBlock(L3BlockTestSubject subject) {
	return L3BlockGetFunction(subject);
}

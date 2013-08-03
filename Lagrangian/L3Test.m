#import "L3Test.h"

#import "Lagrangian.h"

NSString * const L3ErrorDomain = @"com.antitypical.lagrangian";

NSString * const L3ExpectationErrorKey = @"L3ExpectationErrorKey";
NSString * const L3TestErrorKey = @"L3TestErrorKey";

@interface L3Test ()

@property (nonatomic, readonly) L3TestBlock block;

//@property (nonatomic, readonly) NSMutableArray *mutableSteps;
@property (nonatomic, readonly) NSMutableArray *mutableExpectations;
//@property (nonatomic, readonly) NSMutableArray *mutableChildren;

@end

@implementation L3Test

-(instancetype)initWithSourceReference:(id<L3SourceReference>)sourceReference block:(L3TestBlock)block {
	if ((self = [super init])) {
		_sourceReference = sourceReference;
		
		_block = [block copy];
		
//		_mutableSteps = [NSMutableArray new];
		_mutableExpectations = [NSMutableArray new];
//		_mutableChildren = [NSMutableArray new];
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


//-(NSArray *)expectations {
//	return self.mutableExpectations;
//}
//
//-(void)addExpectation:(id<L3Expectation>)expectation {
//	[self.mutableExpectations addObject:expectation];
//}


//-(NSArray *)children {
//	return self.mutableChildren;
//}
//
//-(void)addChild:(L3Test *)test {
//	[self.mutableChildren addObject:test];
//}


//-(void)runSteps {
//	for (L3TestBlock step in self.steps) {
//		step();
//	}
//}

//-(bool)assertExpectation:(id<L3Expectation>)expectation error:(NSError * __autoreleasing *)error {
//	NSParameterAssert(expectation != nil);
//	
//	self.block();
//	
//	bool wasMet = [expectation test];
//	if (!wasMet && error) {
//		NSDictionary *userInfo = @{
//								   L3TestErrorKey: self,
//								   L3ExpectationErrorKey: expectation,
//								   };
//		*error = [NSError errorWithDomain:L3ErrorDomain code:L3AssertionFailedError userInfo:userInfo];
//	}
//	return wasMet;
//}

-(void)run:(L3TestExpectationBlock)callback {
	self.block(callback);
}


l3_test(^{
	NSMutableArray *array = [NSMutableArray new];
	[array addObject:@0];
	
	l3_expect(array.count).to.equal(@1);
	l3_expect(array.lastObject).to.equal(@0);
})


-(id)acceptVisitor:(id<L3TestVisitor>)visitor parents:(NSArray *)parents context:(id)context {
	NSMutableArray *lazyChildren = /*self.children.count? [NSMutableArray new] : */nil;
//	NSArray *childParents = parents?
//		[parents arrayByAddingObject:self]
//	:	@[self];
//	for (L3Test *child in self.children) {
//		[lazyChildren addObject:^{ return [child acceptVisitor:visitor parents:childParents context:context]; }];
//	}
	return [visitor visitTest:self parents:parents lazyChildren:lazyChildren context:context];
}

@end

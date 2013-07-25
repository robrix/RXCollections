#import "L3Test.h"

#import "Lagrangian.h"

@interface L3Test ()

@property (nonatomic, readonly) NSMutableArray *mutablePreconditions;
@property (nonatomic, readonly) NSMutableArray *mutableSteps;
@property (nonatomic, readonly) NSMutableArray *mutableExpectations;
@property (nonatomic, readonly) NSMutableArray *mutableChildren;

@end

@implementation L3Test {
	NSMutableArray *_preconditions;
	NSMutableArray *_steps;
	NSMutableArray *_expectations;
	NSMutableArray *_children;
}

-(instancetype)init {
	if ((self = [super init])) {
		_preconditions = [NSMutableArray new];
		_steps = [NSMutableArray new];
		_expectations = [NSMutableArray new];
		_children = [NSMutableArray new];
	}
	return self;
}


-(NSArray *)preconditions {
	return self.mutablePreconditions;
}

-(void)addPrecondition:(L3TestBlock)block {
	[self.mutablePreconditions addObject:block];
}


-(NSArray *)steps {
	return self.mutableSteps;
}

-(void)addStep:(L3TestBlock)block {
	[self.mutableSteps addObject:block];
}


-(NSArray *)expectations {
	return self.mutableExpectations;
}

-(void)addExpectation:(id)expectation {
	[self.mutableExpectations addObject:expectation];
}


-(NSArray *)children {
	return self.mutableChildren;
}

-(void)addChild:(L3Test *)test {
	[self.mutableChildren addObject:test];
}


l3_test(^{
	
})

-(void)run {
	for (L3TestBlock precondition in self.preconditions) {
		precondition();
	}
	
	for (L3TestBlock step in self.steps) {
		step();
	}
	
	//	for ()
}


l3_test(^{
	__block NSMutableArray *array;
	given(^{ array = [NSMutableArray new]; });
	when(^{
		[array addObject:@0];
	});
	
//	expect(@(array.count)).to.equal(@1);
})



l3_test(^{
	
})

-(id)acceptVisitor:(id<L3TestVisitor>)visitor context:(id)context {
	NSMutableArray *children = [NSMutableArray new];
	for (L3Test *child in self.children) {
		id visited = [child acceptVisitor:visitor context:context];
		if (visited)
			[children addObject:visited];
	}
	return [visitor visitTest:self children:children context:context];
}

@end


L3WhenBlock L3WhenBlockForTest(L3Test *test) {
	return ^(L3TestBlock block){
		if (block)
			[test addStep:block];
	};
}

L3GivenBlock L3GivenBlockForTest(L3Test *test) {
	return ^(L3TestBlock block){
		if (block)
			[test addPrecondition:block];
	};
}

L3ExpectBlock L3ExpectBlockForTest(L3Test *test) {
	return ^(id subject){
		if (subject)
			[test addExpectation:subject];
	};
}

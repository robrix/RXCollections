#import "L3Test.h"

#import "Lagrangian.h"

@interface L3Test ()
@end

@implementation L3Test {
	NSMutableArray *_preconditions;
	NSMutableArray *_steps;
	NSMutableArray *_expectations;
}

-(instancetype)init {
	if ((self = [super init])) {
		_preconditions = [NSMutableArray new];
		_steps = [NSMutableArray new];
		_expectations = [NSMutableArray new];
	}
	return self;
}


-(void)addPrecondition:(L3TestBlock)block {
	[_preconditions addObject:block];
}


-(void)addStep:(L3TestBlock)block {
	[_steps addObject:block];
}


-(void)addExpectation:(id)expectation {
	[_expectations addObject:expectation];
}


l3_test(^{
	
});

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
});

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

#import "L3Test.h"

#import "Lagrangian.h"

@interface L3Test ()

@property (nonatomic, readonly) L3TestBlock block;

@property (nonatomic, readonly) NSMutableArray *mutableSteps;
@property (nonatomic, readonly) NSMutableArray *mutableExpectationIdentifiers;
@property (nonatomic, readonly) NSMutableDictionary *mutableExpectations;
@property (nonatomic, readonly) NSMutableArray *mutableChildren;

@end

@implementation L3Test

-(instancetype)initWithFile:(NSString *)file line:(NSUInteger)line block:(L3TestBlock)block {
	if ((self = [super init])) {
		_file = [file copy];
		_line = line;
		
		_block = [block copy];
		
		_mutableSteps = [NSMutableArray new];
		_mutableExpectationIdentifiers = [NSMutableArray new];
		_mutableExpectations = [NSMutableDictionary new];
		_mutableChildren = [NSMutableArray new];
	}
	return self;
}


-(NSArray *)steps {
	return self.mutableSteps;
}

-(void)addStep:(L3TestBlock)block {
	[self.mutableSteps addObject:block];
}


-(NSArray *)expectations {
	return [self.mutableExpectations objectsForKeys:self.mutableExpectationIdentifiers notFoundMarker:[NSNull null]];
}

-(void)addExpectation:(L3Expectation *)expectation {
	id identifier = expectation.identifier;
	if (![self.mutableExpectations objectForKey:identifier]) {
		[self.mutableExpectationIdentifiers addObject:identifier];
		[self.mutableExpectations setObject:expectation forKey:identifier];
	}
}


-(NSArray *)children {
	return self.mutableChildren;
}

-(void)addChild:(L3Test *)test {
	[self.mutableChildren addObject:test];
}


l3_test(^{
	
})

-(void)runSteps {
	for (L3TestBlock step in self.steps) {
		step();
	}
}

-(void)assertExpectation:(L3Expectation *)expectation {
	self.block();
	
	if (!expectation.wasMet) {
		
	}
}


l3_test(^{
	NSMutableArray *array = [NSMutableArray new];
	[array addObject:@0];
	
	l3_expect(array.count).to.equal(@1);
	l3_expect(array.lastObject).to.equal(@0);
})



l3_test(^{
	
})

-(id)acceptVisitor:(id<L3TestVisitor>)visitor parents:(NSArray *)parents context:(id)context {
	NSMutableArray *children = self.children.count? [NSMutableArray new] : nil;
	NSArray *childParents = parents?
		[parents arrayByAddingObject:self]
	:	@[self];
	for (L3Test *child in self.children) {
		id visited = [child acceptVisitor:visitor parents:childParents context:context];
		if (visited)
			[children addObject:visited];
	}
	return [visitor visitTest:self parents:parents children:children context:context];
}

@end

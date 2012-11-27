//  RXCollectionSetTests.m
//  Created by Rob Rix on 11-11-20.
//  Copyright (c) 2011 Rob Rix. All rights reserved.

#import "RXAssertions.h"
#import "RXCollection.h"
#import "RXCollectionSetTests.h"

@interface RXCollectionSetTests ()
@property (readonly) NSSet *fixture;
@end

@implementation RXCollectionSetTests

-(NSSet *)fixture {
	return [NSSet setWithObjects:@"Pixel", @"Kiwi", @"Maggie", @"Max", nil];
}


-(void)testMappingWithTheIdentityFunctionReturnsAnEqualSet {
	RXAssertEquals([self.fixture rx_mapWithBlock:^(id each) {
		return each;
	}], self.fixture);
}

-(void)testMappingWithAConstantFunctionReturnsASetContainingThatConstant {
	RXAssertEquals([self.fixture rx_mapWithBlock:^(id each) { return @"Bandit"; }], [NSSet setWithObject:@"Bandit"]);
}


-(void)testFilteringReturnsASetIncludingObjectsForWhichTheBlockReturnsTrue {
	RXAssertEquals([self.fixture rx_filterWithBlock:^(id each) { return [each hasPrefix:@"M"]; }], ([NSSet setWithObjects:@"Maggie", @"Max", nil]));
}


-(void)testFoldingWithAnInitialValueReturnsTheResultOfCallingTheBlockWithTheInitialOrPreviousResultAndEachElement {
	RXAssertEquals([self.fixture rx_foldInitialValue:@"" block:^(id memo, id each) {
		return [memo compare:each] == NSOrderedDescending?
			memo
		:	each;
	}], @"Pixel");
}

-(void)testFoldingWithoutAnInitialValueReturnsTheResultOfCallingTheBlockWithNilOrThePreviousResultAndEachElement {
	RXAssertEquals([self.fixture rx_foldWithBlock:^(id memo, id each) {
		return [memo compare:each] == NSOrderedAscending?
			memo
		:	each;
	}], @"Kiwi");
}


-(void)testDetectingReturnsTheFirstEncounteredObjectForWhichTheBlockReturnsTrue {
	id catWhoseNameStartsWithM = [self.fixture rx_detectWithBlock:^(id each) {
		return [each hasPrefix:@"M"];
	}];
	RXAssert([catWhoseNameStartsWithM isEqualToString:@"Maggie"] || [catWhoseNameStartsWithM isEqualToString:@"Max"]);
}

@end

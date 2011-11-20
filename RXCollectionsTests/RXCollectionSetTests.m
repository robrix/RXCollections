//  RXCollectionSetTests.m
//  Created by Rob Rix on 11-11-20.
//  Copyright (c) 2011 Monochrome Industries. All rights reserved.

#import "RXAssertions.h"
#import "RXCollection.h"
#import "RXCollectionSetTests.h"

@implementation RXCollectionSetTests

-(NSSet *)fixture {
	return [NSSet setWithObjects:@"Pixel", @"Kiwi", @"Maggie", @"Max", nil];
}


-(void)testMappingWithTheIdentityFunctionReturnsAnEqualSet {
	RXAssertEquals([NSSet rx_setByMappingCollection:self.fixture withBlock:^(id each) {
		return each;
	}], self.fixture);
}

-(void)testMappingWithAConstantFunctionReturnsASetContainingThatConstant {
	RXAssertEquals([NSSet rx_setByMappingCollection:self.fixture withBlock:^(id each) { return @"Bandit"; }], [NSSet setWithObject:@"Bandit"]);
}


-(void)testFilteringReturnsASetIncludingObjectsForWhichTheBlockReturnsTrue {
	RXAssertEquals([NSSet rx_setByFilteringCollection:self.fixture withBlock:^(id each) { return [each hasPrefix:@"M"]; }], ([NSSet setWithObjects:@"Maggie", @"Max", nil]));
}


-(void)testFoldingWithAnInitialValueReturnsTheResultOfCallingTheBlockWithTheInitialOrPreviousResultAndEachElement {
	RXAssertEquals([self.fixture rx_foldInitialValue:@"" withBlock:^(id memo, id each) {
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

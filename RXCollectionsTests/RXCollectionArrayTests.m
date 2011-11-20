//  RXCollectionArrayTests.m
//  Created by Rob Rix on 11-11-20.
//  Copyright (c) 2011 Monochrome Industries. All rights reserved.

#import "RXAssertions.h"
#import "RXCollection.h"
#import "RXCollectionArrayTests.h"

@implementation RXCollectionArrayTests

-(NSArray *)fixture {
	return [NSArray arrayWithObjects:@"Pixel", @"Kiwi", @"Maggie", @"Max", nil];
}


-(void)testMappingWithTheIdentityFunctionReturnsAnEqualArray {
	RXAssertEquals([NSArray rx_arrayByMappingCollection:self.fixture withBlock:^(id each) {
		return each;
	}], self.fixture);
}

-(void)testMappingWithAConstantFunctionReturnsAnArrayContainingNOfThatConstant {
	RXAssertEquals([NSArray rx_arrayByMappingCollection:self.fixture withBlock:^(id each) { return @"Bandit"; }], ([NSArray arrayWithObjects:@"Bandit", @"Bandit", @"Bandit", @"Bandit", nil]));
}


-(void)testFilteringReturnsAnArrayIncludingObjectsForWhichTheBlockReturnsTrue {
	RXAssertEquals([NSArray rx_arrayByFilteringCollection:self.fixture withBlock:^(id each) { return [each hasPrefix:@"M"]; }], ([NSArray arrayWithObjects:@"Maggie", @"Max", nil]));
}


-(void)testFoldingWithAnInitialValueReturnsTheResultOfCallingTheBlockWithTheInitialOrPreviousResultAndEachElement {
	RXAssertEquals([self.fixture rx_foldInitialValue:@"" withBlock:^(id memo, id each) {
		return [memo stringByAppendingString:each];
	}], @"PixelKiwiMaggieMax");
}

-(void)testFoldingWithoutAnInitialValueReturnsTheResultOfCallingTheBlockWithNilOrThePreviousResultAndEachElement {
	RXAssertEquals([self.fixture rx_foldWithBlock:^(id memo, id each) {
		return [each stringByAppendingString:memo ?: @""];
	}], @"MaxMaggieKiwiPixel");
}


-(void)testDetectingReturnsTheFirstEncounteredObjectForWhichTheBlockReturnsTrue {
	RXAssertEquals([self.fixture rx_detectWithBlock:^(id each) {
		return [each hasPrefix:@"M"];
	}], @"Maggie");
}


@end

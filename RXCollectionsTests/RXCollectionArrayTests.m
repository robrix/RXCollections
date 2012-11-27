//  RXCollectionArrayTests.m
//  Created by Rob Rix on 11-11-20.
//  Copyright (c) 2011 Rob Rix. All rights reserved.

#import "RXAssertions.h"
#import "RXCollection.h"
#import "RXCollectionArrayTests.h"

@interface RXCollectionArrayTests ()
@property (readonly) NSArray *fixture;
@end

@implementation RXCollectionArrayTests

-(NSArray *)fixture {
	return [NSArray arrayWithObjects:@"Pixel", @"Kiwi", @"Maggie", @"Max", nil];
}


-(void)testMappingWithTheIdentityFunctionReturnsAnEqualArray {
	RXAssertEquals([self.fixture rx_mapWithBlock:RXCollectionIdentityBlock], self.fixture);
}

-(void)testMappingWithAConstantFunctionReturnsAnArrayContainingNOfThatConstant {
	RXAssertEquals([self.fixture rx_mapWithBlock:^(id each) { return @"Bandit"; }], ([NSArray arrayWithObjects:@"Bandit", @"Bandit", @"Bandit", @"Bandit", nil]));
}


-(void)testFilteringReturnsAnArrayIncludingObjectsForWhichTheBlockReturnsTrue {
	RXAssertEquals([self.fixture rx_filterWithBlock:^(id each) { return [each hasPrefix:@"M"]; }], ([NSArray arrayWithObjects:@"Maggie", @"Max", nil]));
}


-(void)testFoldingWithAnInitialValueReturnsTheResultOfCallingTheBlockWithTheInitialOrPreviousResultAndEachElement {
	RXAssertEquals([self.fixture rx_foldInitialValue:@"" block:^(id memo, id each) {
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

#import <XCTest/XCTest.h>

#import <RXPreprocessing/RXPreprocessing.h>

@interface RXPreprocessingTests : XCTestCase
@end

@implementation RXPreprocessingTests

-(void)testInterpolationConstructsStrings {
	XCTAssertEqualObjects(rx_q(1), @"1");
	XCTAssertEqualObjects(rx_q(1, @2, @"3"), @"123");
}

@end

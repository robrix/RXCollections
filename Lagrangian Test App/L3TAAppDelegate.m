//  L3TAAppDelegate.m
//  Created by Rob Rix on 2012-11-09.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TAAppDelegate.h"
#import "Lagrangian.h"

@l3_suite("App delegate");

@l3_setUp {
	// make a delegate
}

@interface L3TAAppDelegate ()

@end

@implementation L3TAAppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)notification {
	NSLog(@"applicationDidFinishLaunching:");
}

@l3_test("") {
	NSLog(@"this is a test of tests");
}

@end

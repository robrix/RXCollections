//  L3TAAppDelegate.m
//  Created by Rob Rix on 2012-11-09.
//  Copyright (c) 2012 Rob Rix. All rights reserved.

#import "L3TAAppDelegate.h"
#import "Lagrangian.h"

@l3_suite_state("App delegate")
@property L3TAAppDelegate *appDelegate;
@end

@interface L3TAAppDelegate ()
@end

@implementation L3TAAppDelegate

@l3_suite("App delegate 2");

@l3_set_up {
	state.appDelegate = [L3TAAppDelegate new];
}


-(void)applicationDidFinishLaunching:(NSNotification *)notification {
	NSLog(@"applicationDidFinishLaunching:");
}

@l3_test(" state ") {
	NSLog(@"this is a test of tests: %@", [(id)state appDelegate]);
}

@end

//
//  MTCustomTimerCommand.m
//  miniTimer
//
//  Created by Kevin Gessner on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MTCustomTimerCommand.h"
#import "MTController.h"

@implementation MTCustomTimerCommand

- (id)performDefaultImplementation {
	MTController *controller = (MTController *)[NSApp delegate]; // i think this is the only way to get to the controller from here
	[controller startCustomTimer:nil];
	return nil;
}

@end

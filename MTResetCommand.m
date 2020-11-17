//
//  MTResetCommand.m
//  miniTimer
//
//  Created by Kevin Gessner on 8/3/07.
//  Copyright 2007 Kevin Gessner. All rights reserved.
//

#import "MTResetCommand.h"
#import "MTController.h"


@implementation MTResetCommand

- (id)performDefaultImplementation {
	MTController *controller = (MTController *)[NSApp delegate]; // i think this is the only way to get to the controller from here
	[controller resetTimer:0];
	return nil;
}

@end

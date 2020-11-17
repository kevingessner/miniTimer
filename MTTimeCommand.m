//
//  MTTimeCommand.m
//  miniTimer
//
//  Created by Kevin Gessner on 8/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MTTimeCommand.h"
#import "MTController.h"
#import "MTTimeFormatter.h"

@implementation MTTimeCommand

- (id)performDefaultImplementation {
	MTController *controller = (MTController *)[NSApp delegate]; // i think this is the only way to get to the controller from here
	[controller setTimer:[MTTimeFormatter HMSToSeconds:[[self arguments] objectForKey:@"duration"]]];
	return nil;
}

@end

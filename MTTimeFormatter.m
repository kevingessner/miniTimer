//
//  MTTimeFormatter.m
//  miniTimer
//
//  Created by Kevin Gessner on 6/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "MTTimeFormatter.h"


@implementation MTTimeFormatter

+ (double)HMSToSeconds:(NSString *)hms {
	NSArray *times = [hms componentsSeparatedByString:@":"];
	if(1 == [times count]) return [[times objectAtIndex:0] doubleValue];
	if(2 == [times count]) return [[times objectAtIndex:0] doubleValue] * 60 + [[times objectAtIndex:1] doubleValue];
	if(3 == [times count]) return [[times objectAtIndex:0] doubleValue] * 3600 + [[times objectAtIndex:1] doubleValue] * 60 + [[times objectAtIndex:2] doubleValue];
	return 0;
}

+ (NSString*)secondsToHMS:(double)seconds {
	if(seconds < 60)
		return [NSString stringWithFormat:@"0:%02.0f",seconds];
	if(seconds < 3600) {
		double minutes = floor(seconds/60);
		double secondsLeftover = seconds - minutes * 60;
		return [NSString stringWithFormat:@"%1.0f:%02.0f",minutes,secondsLeftover];
	} else {
		double hours = floor(seconds/3600);
		double minutesLeftover = floor((seconds - hours * 3600)/60);
		double secondsLeftover = seconds - hours * 3600 - minutesLeftover * 60;
		return [NSString stringWithFormat:@"%1.0f:%02.0f:%02.0f",hours,minutesLeftover,secondsLeftover];		
	}
	return nil;
}

@end

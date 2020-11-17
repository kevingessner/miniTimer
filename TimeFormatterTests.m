//
//  TimeFormatterTests.m
//  miniTimer
//
//  Created by Kevin Gessner on 7/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TimeFormatterTests.h"
#import "TimeFormatter.h"

@implementation TimeFormatterTests

- (void)testHMSToSeconds {
	STAssertEquals(0.0, [TimeFormatter HMSToSeconds:@"foo"], @"0.0 and foo");
	STAssertEquals(0.0, [TimeFormatter HMSToSeconds:@"0"], @"0.0 and 0");
	STAssertEquals(23.0, [TimeFormatter HMSToSeconds:@"23"], @"23.0 and 23");
	STAssertEquals(26.0, [TimeFormatter HMSToSeconds:@"0:26"], @"26.0 and 0:26");
	STAssertEquals(60.0, [TimeFormatter HMSToSeconds:@"1:0"], @"60.0 and 1:00");
	STAssertEquals(89.0, [TimeFormatter HMSToSeconds:@"1:29"], @"89.0 and 1:29");
	STAssertEquals(3600.0, [TimeFormatter HMSToSeconds:@"1:00:00"], @"3600 and 1:00:00");
	STAssertEquals(3720.0, [TimeFormatter HMSToSeconds:@"1:02:00"], @"3720 and 1:02:00");
	STAssertEquals(3613.0, [TimeFormatter HMSToSeconds:@"1:00:13"], @"3613 and 1:00:13");
	STAssertEquals(3781.0, [TimeFormatter HMSToSeconds:@"1:03:01"], @"3781 and 1:03:01");
}

@end

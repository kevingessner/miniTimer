//
//  MTTimeFormatter.h
//  miniTimer
//
//  Created by Kevin Gessner on 6/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MTTimeFormatter : NSObject {

}

+ (NSString*)secondsToHMS:(double)seconds;
+ (double)HMSToSeconds:(NSString *)hms;

@end
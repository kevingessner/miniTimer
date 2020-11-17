//
//  MTController.m
//  miniTimer
//
//  Created by Kevin Gessner on 6/12/06.
//  Copyright 2006. All rights reserved.
//

#import "MTController.h"
#import "MTTimeFormatter.h"
#import "PTHotKey.h"
#import "PTHotKeyCenter.h"
#import "PTKeyComboPanel.h"
#import <Growl/GrowlApplicationBridge.h>

int sortScreens(id s1, id s2, void *context) {
	int *edge;
	edge = (int *)context;
	switch((int)edge) {
		case NSMaxXEdge:
			if(([s1 frame].origin.x + [s1 frame].size.width) > ([s2 frame].origin.x + [s2 frame].size.width)) return NSOrderedAscending;
			else if(([s1 frame].origin.x + [s1 frame].size.width) < ([s2 frame].origin.x + [s2 frame].size.width)) return NSOrderedDescending;
			else return NSOrderedSame;
		case NSMinXEdge:
			if(([s1 frame].origin.x) < ([s2 frame].origin.x)) return NSOrderedAscending;
			else if(([s1 frame].origin.x) > ([s2 frame].origin.x)) return NSOrderedDescending;
			else return NSOrderedSame;
	}
	return 0;
}

@implementation MTController

#pragma mark Setup methods

- (id)init {
	self = [super init];
	[GrowlApplicationBridge setGrowlDelegate:self];
	[self setupDefaults];
	return self;
}

- (void)awakeFromNib {
	[self registerAsObserver];
	[self setupHotKey];
	
	customTimerFrame = NSZeroRect;
}

- (void)registerAsObserver {
	[[NSUserDefaults standardUserDefaults] addObserver:self
										    forKeyPath:@"Opacity"
											   options:NSKeyValueObservingOptionNew
											   context:NULL];
	[self observeValueForKeyPath:@"Opacity" ofObject:nil change:nil context:nil];
											   
	[[NSUserDefaults standardUserDefaults] addObserver:self
										    forKeyPath:@"ScreenEdge"
											   options:NSKeyValueObservingOptionNew
											   context:NULL];
	[self observeValueForKeyPath:@"ScreenEdge" ofObject:nil change:nil context:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification:) name:NSApplicationDidChangeScreenParametersNotification object:nil];
}

- (void)setupDefaults {
	NSMutableDictionary *appDefaults = [NSMutableDictionary dictionaryWithCapacity:6];
	
	[appDefaults setObject:[NSNumber numberWithInt:NSMaxYEdge] forKey:@"ScreenEdge"];
	[appDefaults setObject:[NSNumber numberWithFloat:1.0] forKey:@"Opacity"];
	
	[appDefaults setValue:@"YES" forKey:@"BounceIconNotification"];
	if([GrowlApplicationBridge isGrowlRunning]) { // default to growl instead if it is installed and running
		[appDefaults setValue:@"" forKey:@"AlertNotification"];
		[appDefaults setValue:@"YES" forKey:@"GrowlNotification"];
		[appDefaults setValue:@"" forKey:@"StickyGrowlNotification"];
	} else {
		[appDefaults setValue:@"YES" forKey:@"AlertNotification"];
		[appDefaults setValue:@"" forKey:@"GrowlNotification"];
		[appDefaults setValue:@"" forKey:@"StickyGrowlNotification"];
	}

    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
}

// size the window to the given screen edge, then put the custom timer drawer in the right place
- (void)sizeWindowToScreenEdge:(NSRectEdge)edge {
	char thickness = 25, // desired thickness of window and bar
		frame_offset = -2; // constant difference between edge of frame and edge of displayed area
	int extra_size = 300; // extra window size, since the drawer doesn't like being attached to a very thin window. this extra area is off-screen.
	
	NSScreen *screen = [self screenWithEdge:edge];
	if(NSEqualRects(customTimerFrame, NSZeroRect)) customTimerFrame = [customTimerView frame];
	
	if(NSMaxYEdge == edge) { // bottom of screen
		[[self window] setFrame:NSMakeRect([screen frame].origin.x + frame_offset, [screen frame].origin.y + frame_offset - extra_size, [screen frame].size.width - frame_offset, thickness + extra_size) display:NO];
		[tBar setFrameRotation:0];
		[tBar setFrame:NSMakeRect(frame_offset, [[self window] frame].size.height - thickness + 2 * frame_offset, [[self window] frame].size.width - 2 * frame_offset, thickness - frame_offset)];
		[[self window] display];
		
		[customTimerDrawer release];
		customTimerDrawer = [[NSDrawer alloc] initWithContentSize:customTimerFrame.size preferredEdge:NSMaxYEdge];
		[customTimerDrawer setParentWindow:[self window]];
		[customTimerDrawer setLeadingOffset:25];
		[customTimerDrawer setTrailingOffset:[[self window] frame].size.width - customTimerFrame.size.width - [customTimerDrawer leadingOffset] - 20];
		[customTimerDrawer setContentView:customTimerView];
		[customTimerDrawer setMaxContentSize:[customTimerDrawer contentSize]];
		[customTimerDrawer setMinContentSize:[customTimerDrawer contentSize]];
		
		return;
	}
	
	if(NSMinXEdge == edge) { // left edge of screen
		[[self window] setFrame:NSMakeRect([screen frame].origin.x + frame_offset - extra_size, [screen frame].origin.y + frame_offset - MENU_BAR_HEIGHT, thickness + extra_size, [screen frame].size.height - frame_offset) display:NO];
		[tBar setFrameRotation:90];
		[tBar setFrame:NSMakeRect(thickness - 2 * frame_offset + extra_size, frame_offset, [[self window] frame].size.height - 2 * frame_offset, thickness - frame_offset)];
		[[self window] display];
		
		[customTimerDrawer release];
		customTimerDrawer = [[NSDrawer alloc] initWithContentSize:customTimerFrame.size preferredEdge:NSMaxXEdge];
		[customTimerDrawer setParentWindow:[self window]];
		[customTimerDrawer setLeadingOffset:25];
		[customTimerDrawer setTrailingOffset:[[self window] frame].size.height - customTimerFrame.size.height - [customTimerDrawer leadingOffset] - 20];
		[customTimerDrawer setContentView:customTimerView];
		[customTimerDrawer setMaxContentSize:[customTimerDrawer contentSize]];
		[customTimerDrawer setMinContentSize:[customTimerDrawer contentSize]];
		
		return;
	}
	
	if(NSMaxXEdge == edge) { // right edge of screen
		[[self window] setFrame:NSMakeRect([screen frame].size.width - thickness - 2 * frame_offset, [screen frame].origin.y + frame_offset - MENU_BAR_HEIGHT, thickness + extra_size, [screen frame].size.height - frame_offset) display:NO];
		[tBar setFrameRotation:90];
		[tBar setFrame:NSMakeRect(thickness - 2 * frame_offset, frame_offset, [[self window] frame].size.height - 2 * frame_offset, thickness - frame_offset)];
		[[self window] display];
		
		[customTimerDrawer release];
		customTimerDrawer = [[NSDrawer alloc] initWithContentSize:customTimerFrame.size preferredEdge:NSMaxXEdge];
		[customTimerDrawer setParentWindow:[self window]];
		[customTimerDrawer setLeadingOffset:25];
		[customTimerDrawer setTrailingOffset:[[self window] frame].size.height - customTimerFrame.size.height - [customTimerDrawer leadingOffset] - 20];
		[customTimerDrawer setContentView:customTimerView];
		[customTimerDrawer setMaxContentSize:[customTimerDrawer contentSize]];
		[customTimerDrawer setMinContentSize:[customTimerDrawer contentSize]];
		
		return;
	}
}

- (NSScreen *)screenWithEdge:(NSRectEdge)edge {
	NSArray *screens = [NSScreen screens];
	if([screens count] == 1 || NSMaxYEdge == edge) return [screens objectAtIndex:0];
	NSArray *sortedScreens = [screens sortedArrayUsingFunction:sortScreens context:(void *)edge];
	return [sortedScreens objectAtIndex:0];
}



#pragma mark The timer guts

- (void)timerFire:(NSTimer*)theTimer {
	[self setCurrentTime:[self currentTime] + 1];
	[tBar setToolTip:[self currentTimeString]];
	if([self currentTime] == [self duration]) [self timeUp];
}

- (NSString *)currentTimeString {
	return [NSString stringWithFormat:@"%@/%@ elapsed",[MTTimeFormatter secondsToHMS:[self currentTime]],[MTTimeFormatter secondsToHMS:[self duration]]];
}

- (void)startTimer {
	if(timer != nil)
		return;
	
	timer = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFire:) userInfo:nil repeats:YES] retain];
}

- (IBAction)stopTimer:(id)sender {
	if(timer == nil)
		return;
	
	[timer invalidate];
	[timer release];
	timer = nil;
}

- (void)timeUp {
	[self stopTimer:nil];
		
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlNotification"]) {
		[GrowlApplicationBridge
			notifyWithTitle:@"Time's Up!"
				description:[NSString stringWithFormat:@"%@ has elapsed.",[MTTimeFormatter secondsToHMS:[self duration]]]
			notificationName:@"Time's Up!"
				   iconData:nil
				   priority:0.0
				   isSticky:[[NSUserDefaults standardUserDefaults] boolForKey:@"StickyGrowlNotification"]
			   clickContext:nil];
	}
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"BounceIconNotification"]) {
		[NSApp requestUserAttention:NSCriticalRequest];
	}
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"AlertNotification"]) {
		[NSApp activateIgnoringOtherApps:YES];
		NSRunAlertPanel(@"Time's Up!",[NSString stringWithFormat:@"%@ has elapsed.",[MTTimeFormatter secondsToHMS:[self duration]]],@"OK",nil,nil);
	}
}

- (void)setTimer:(double)duration {
	[self stopTimer:nil];
	[self setCurrentTime:0];
	[tBar setToolTip:nil];
	if(duration > 0) {
		[self setDuration:duration];
		[self startTimer];
	}
}

- (double)duration { return (_duration > 0 ? _duration : 0.1); }
- (void)setDuration:(double)duration {
	_duration = duration;
}

- (double)currentTime { return _currentTime; }
- (void)setCurrentTime:(double)time {
	_currentTime = time;
}

#pragma mark IB Actions

- (IBAction)resetTimer:(id)sender {
	[self setTimer:[sender tag]];
}

- (IBAction)showHelp:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[@"file://" stringByAppendingString:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/help.htm"]]]];
}

// custom timers

- (IBAction)startCustomTimer:(id)sender {
	[NSApp activateIgnoringOtherApps:YES];
	[customTimerDrawer open];
	[[self window] makeFirstResponder:customTimerForm];
}

- (IBAction)doCustomTimer:(id)sender {
	[self setTimer:[MTTimeFormatter HMSToSeconds:[customTimerField stringValue]]];
	[customTimerDrawer close];
}

- (void)customTimerService:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
	[self doCustomTimer:nil];
}

- (IBAction)cancelCustomTimer:(id)sender {
	[customTimerDrawer close];
}

- (IBAction)toggleCustomTimer:(id)sender {
	if(NSDrawerOpenState == [customTimerDrawer state]) [self cancelCustomTimer:self];
	else [self startCustomTimer:self];
}

#pragma mark NSApplication delegate methods

// stops the app from quitting immediately while a timer is running
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	if(timer != nil) {
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"Quit Anyway"];
		[alert addButtonWithTitle:@"Never Mind"];
		[alert setMessageText:@"Really quit?"];
		[alert setInformativeText:@"A timer is currently running. If you quit, the timer will be cancelled."];
		[alert setAlertStyle:NSWarningAlertStyle];
		int result = [alert runModal];
		if(result == NSAlertSecondButtonReturn) return NSTerminateCancel;
	}
	return NSTerminateNow;
}

- (void)processNotification:(NSNotification *)notification {
	if([[notification name] isEqualToString:NSApplicationDidChangeScreenParametersNotification])
		[self sizeWindowToScreenEdge:(NSRectEdge)[[NSUserDefaults standardUserDefaults] integerForKey:@"ScreenEdge"]];
}

#pragma mark Applescript

- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key {
	if([key isEqualToString:@"currentTime"]) return YES;
	if([key isEqualToString:@"duration"]) return YES;
	return NO;
}

#pragma mark Growl notification setup

- (NSDictionary *) registrationDictionaryForGrowl {
	NSArray *notifications = [NSArray arrayWithObject:@"Time's Up!"];
	
	NSArray *returnKeys = [NSArray arrayWithObjects:GROWL_NOTIFICATIONS_ALL, GROWL_NOTIFICATIONS_DEFAULT, nil];
	NSArray *returnObjects = [NSArray arrayWithObjects:notifications, notifications, nil];
	return [NSDictionary dictionaryWithObjects:returnObjects forKeys:returnKeys];
}

- (NSString *) applicationNameForGrowl {
	return @"miniTimer";
}

#pragma mark Hotkeys

- (void)hotKeySheetDidEndWithReturnCode: (NSNumber*)resultCode
{
	if( [resultCode intValue] == NSOKButton )
	{
		//Update our hotkey with the new keycombo
		[mHotKey setKeyCombo: [[PTKeyComboPanel sharedPanel] keyCombo]];
		
		//Re-register it (required)
		[[PTHotKeyCenter sharedCenter] registerHotKey: mHotKey];
		
		[hotKeyDisplay setStringValue:[[mHotKey keyCombo] description]];
		
		
		//[customTimerMenu setKeyEquivalent:[PTKeyCombo _stringForKeyCode:[[mHotKey keyCombo] keyCode]]];
		//[customTimerMenu setKeyEquivalentModifierMask:[[mHotKey keyCombo] modifiers]];
		
		//Save our keycombo to preferences
		[[NSUserDefaults standardUserDefaults] setObject: [[mHotKey keyCombo] plistRepresentation] forKey: @"customTimerHotkey"];
	}
}

- (IBAction)hitSetHotKey: (id)sender
{
	PTKeyComboPanel* panel = [PTKeyComboPanel sharedPanel];
	[panel setKeyCombo: [mHotKey keyCombo]];
	[panel setKeyBindingName: [mHotKey name]];
	[panel runSheeetForModalWindow: preferencesWindow target: self];
}

- (void)setupHotKey
{
	id keyComboPlist;
	PTKeyCombo* keyCombo = nil;
	
	//Read our keycombo in from preferences
	keyComboPlist = [[NSUserDefaults standardUserDefaults] objectForKey: @"customTimerHotkey"];
	keyCombo = [[[PTKeyCombo alloc] initWithPlistRepresentation: keyComboPlist] autorelease];
	
	//Create our hot key
	mHotKey = [[PTHotKey alloc] initWithIdentifier: @"customTimerHotkey" keyCombo: keyCombo];	
	[mHotKey setName: @"Start Custom Timer"]; //This is typically used by PTKeyComboPanel
	[mHotKey setTarget: self];
	[mHotKey setAction: @selector( toggleCustomTimer: ) ];
	
	//Register it
	[[PTHotKeyCenter sharedCenter] registerHotKey: mHotKey];
	
	//[customTimerMenu setKeyEquivalent:[PTKeyCombo _stringForKeyCode:[[mHotKey keyCombo] keyCode]]];
	//[customTimerMenu setKeyEquivalentModifierMask:[[mHotKey keyCombo] modifiers]];
	
	[hotKeyDisplay setStringValue:[[mHotKey keyCombo] description]];
}

#pragma mark Bindings

- (void)observeValueForKeyPath:(NSString *)keyPath
              ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"Opacity"]) {
		[[self window] setAlphaValue:[[NSUserDefaults standardUserDefaults] floatForKey:keyPath]];
    } else if([keyPath isEqual:@"ScreenEdge"]) {
		[self sizeWindowToScreenEdge:(NSRectEdge)[[NSUserDefaults standardUserDefaults] integerForKey:keyPath]];
	}
	
    // be sure to call the super implementation
    // if the superclass implements it
    /*[super observeValueForKeyPath:keyPath
                ofObject:object
                 change:change
                 context:context];*/
}

@end
//
//  MTController.h
//  miniTimer
//
//  Created by Kevin Gessner on 6/12/06.
//  Copyright 2006. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol GrowlApplicationBridgeDelegate;
#import <Growl/GrowlApplicationBridge.h>
@class PTHotKey;

#define MENU_BAR_HEIGHT 22

@interface MTController : NSWindowController <GrowlApplicationBridgeDelegate> {
	IBOutlet NSProgressIndicator *tBar;
	
	NSDrawer *customTimerDrawer;
	IBOutlet NSView *customTimerView;
	IBOutlet NSFormCell *customTimerField;
	IBOutlet NSForm *customTimerForm;
	IBOutlet NSMenuItem *customTimerMenu;
	
	NSTimer *timer;
	
	PTHotKey *mHotKey;
	
	IBOutlet NSWindow *preferencesWindow;
	IBOutlet NSTextField *hotKeyDisplay;
	
	bool hasGrowl;
	NSRect customTimerFrame;
	double _duration, _currentTime;
}

- (void)setupDefaults;
- (void)registerAsObserver;
- (void)sizeWindowToScreenEdge:(NSRectEdge)edge;
- (NSScreen *)screenWithEdge:(NSRectEdge)edge;
- (void)startTimer;
- (IBAction)stopTimer:(id)sender;
- (void)timeUp;
- (void)timerFire:(NSTimer*)theTimer;
- (void)setTimer:(double)duration;
- (IBAction)resetTimer:(id)sender;
- (IBAction)showHelp:(id)sender;

- (void)setDuration:(double)duration;
- (double)duration;
- (void)setCurrentTime:(double)time;
- (double)currentTime;
- (NSString *)currentTimeString;

- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key;

- (IBAction)startCustomTimer:(id)sender;
- (IBAction)doCustomTimer:(id)sender;
- (IBAction)cancelCustomTimer:(id)sender;

- (void)setupHotKey;
- (IBAction)hitSetHotKey: (id)sender;
- (void)hotKeySheetDidEndWithReturnCode: (NSNumber*)resultCode;

@end

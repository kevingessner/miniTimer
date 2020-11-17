#import "MTWindow.h"
#import <AppKit/AppKit.h>

@implementation MTWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {

    NSWindow* result = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];

    [result setBackgroundColor: [NSColor clearColor]];

    [result setLevel: NSStatusWindowLevel];
	
    [result setAlphaValue:1.0];
    [result setOpaque:NO];
	
    [result setHasShadow: NO];
    return result;
}

- (BOOL) canBecomeKeyWindow
{
    return YES;
}

- (BOOL)_hasActiveControls {
	return YES;
}

@end

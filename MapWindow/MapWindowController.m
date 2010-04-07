//
//  MapWindowController.m
//  Map
//
//  Created by Tobias Kräntzer on 07.04.10.
//  Copyright 2010 Konoco. All rights reserved.
//

#import "MapWindowController.h"
#import "MapView.h"

@implementation MapWindowController

@synthesize mapView;

- (id)init {
	if (self = [super initWithWindowNibName:@"MapWindow"]) {
		[self.window setExcludedFromWindowsMenu:YES];
	}
	return self;
}

#pragma mark -
#pragma mark Actions

- (IBAction)zoomIn:(id)sender {
	[self.mapView setZoom:floor(self.mapView.zoom) + 1 animated:YES];
}

- (IBAction)zoomOut:(id)sender {
	[self.mapView setZoom:floor(self.mapView.zoom) - 1 animated:YES];
}

- (IBAction)toggleFullscreen:(id)sender {
	CGDisplayFadeReservationToken token;
	CGDisplayErr err;
	err = CGAcquireDisplayFadeReservation (kCGMaxDisplayReservationInterval, &token);
	if (err == kCGErrorSuccess)
	{
		err = CGDisplayFade (token, 0.25, kCGDisplayBlendNormal, kCGDisplayBlendSolidColor, 0, 0, 0, true);
		err = CGDisplayCapture (kCGDirectMainDisplay);
		if ([self.mapView isInFullScreenMode]) {
			[self.mapView exitFullScreenModeWithOptions:NULL];
		} else {
			[self.mapView enterFullScreenMode:[self.mapView.window screen] withOptions:NULL];
		}
		err = CGDisplayFade (token, 0.25, kCGDisplayBlendSolidColor, kCGDisplayBlendNormal, 0, 0, 0, true);
		err = CGReleaseDisplayFadeReservation (token);
	}
}

@end

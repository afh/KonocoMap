//
//  MapAppDelegate.m
//  Map
//
//  Created by Tobias Kräntzer on 07.04.10.
//  Copyright 2010 Konoco. All rights reserved.
//

#import "MapAppDelegate.h"

// controller
#import "MapWindowController.h"
#import "NavigationPanelController.h"
#import "PreferenceController.h"


@implementation MapAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	
	[self showMapWindow:self];
}

#pragma mark -
#pragma mark Actions

- (IBAction)showMapWindow:(id)sender {
	if (!mapWindowController) {
		mapWindowController = [MapWindowController new];
		[mapWindowController addObserver:self
							  forKeyPath:@"region"
								 options:NSKeyValueObservingOptionNew
								 context:NULL];
	}
	[mapWindowController showWindow:self];
	[mapWindowController.window makeKeyAndOrderFront:nil];
}

- (IBAction)showNavigation:(id)sender {
	if (!navigationPanelController) {
		navigationPanelController = [NavigationPanelController new];
		if (mapWindowController) {
			[navigationPanelController setRegion:mapWindowController.region];
		}
	}
	[navigationPanelController showWindow:self];
}

- (IBAction)showPreference:(id)sender {
	if (!preferenceController) {
		preferenceController = [PreferenceController new];
	}
	[preferenceController showWindow:self];
}

- (IBAction)zoomIn:(id)sender {
	if (mapWindowController) {
		[mapWindowController zoomIn:self];
	}
}

- (IBAction)zoomOut:(id)sender {
	if (mapWindowController) {
		[mapWindowController zoomOut:self];
	}
}

- (IBAction)toggleFullscreen:(id)sender {
	if (mapWindowController) {
		[mapWindowController toggleFullscreen:self];
	}
}

#pragma mark -
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
	if (object == mapWindowController) {
		if ([keyPath isEqual:@"region"]) {
			if (navigationPanelController) {
				[navigationPanelController setRegion:mapWindowController.region];
			}
		}
	}
}

@end

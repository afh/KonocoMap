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
}

#pragma mark -
#pragma mark Actions

- (IBAction)showMapWindow:(id)sender {
	if (!mapWindowController) {
		mapWindowController = [MapWindowController new];
	}
	[mapWindowController showWindow:self];
}

- (IBAction)showNavigation:(id)sender {
	if (!navigationPanelController) {
		navigationPanelController = [NavigationPanelController new];
	}
	[navigationPanelController showWindow:self];
}

- (IBAction)showPreference:(id)sender {
	if (!preferenceController) {
		preferenceController = [PreferenceController new];
	}
	[preferenceController showWindow:self];
}

@end

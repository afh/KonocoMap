//
//  MapAppDelegate.m
//  Map
//
//  Created by Tobias Kräntzer on 07.04.10.
//  Copyright 2010 Konoco <http://konoco.org/> All rights reserved.
//
//  This file is part of Map.
//	
//  Map is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//	
//  Map is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with Map.  If not, see <http://www.gnu.org/licenses/>.

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

//
//  MapAppDelegate.h
//  Map
//
//  Created by Tobias Kräntzer on 07.04.10.
//  Copyright 2010 Konoco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MapWindowController;
@class NavigationPanelController;
@class PreferenceController;

@interface MapAppDelegate : NSObject {
	MapWindowController *mapWindowController;
	NavigationPanelController *navigationPanelController;
	PreferenceController *preferenceController;
}

#pragma mark -
#pragma mark Actions

- (IBAction)showMapWindow:(id)sender;
- (IBAction)showNavigation:(id)sender;
- (IBAction)showPreference:(id)sender;

@end

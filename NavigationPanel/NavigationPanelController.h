//
//  NavigationPanelController.h
//  Map
//
//  Created by Tobias Kräntzer on 07.04.10.
//  Copyright 2010 Konoco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NavigationView;

@interface NavigationPanelController : NSWindowController {
	IBOutlet NavigationView *navigationView;
}

#pragma mark -
#pragma mark Region

- (void)setRegion:(CGRect)rect;

@end

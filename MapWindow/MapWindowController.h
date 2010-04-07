//
//  MapWindowController.h
//  Map
//
//  Created by Tobias Kräntzer on 07.04.10.
//  Copyright 2010 Konoco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MapView;

@interface MapWindowController : NSWindowController {
	IBOutlet MapView *mapView;
}

@property (nonatomic, readonly) IBOutlet MapView *mapView;

@end

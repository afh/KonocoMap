//
//  NavigationView.h
//  Map
//
//  Created by Tobias Kräntzer on 07.04.10.
//  Copyright 2010 Konoco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MapLayer;

@interface NavigationView : NSView {
	MapLayer *mapLayer;
	CGRect region;
}

@property (nonatomic, assign) CGRect region;

@end

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

#pragma mark -
#pragma mark Actions

- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (IBAction)toggleFullscreen:(id)sender;

#pragma mark -
#pragma mark Zoom, Center & Region

@property (nonatomic, assign) CGFloat zoom;
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGRect region;

- (void)setZoom:(CGFloat)level animated:(BOOL)animated;
- (void)setCenter:(CGPoint)point animated:(BOOL)animated;
- (void)setRegion:(CGRect)rect animated:(BOOL)animated;

@end

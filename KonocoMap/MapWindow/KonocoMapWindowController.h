//
//  KonocoMapWindowController.h
//  KonocoMap
//
//  Created by Tobias Kräntzer on 07.04.10.
//  Copyright 2010 Konoco <http://konoco.org/> All rights reserved.
//
//  This file is part of Konoco Map.
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

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>
#import <KonocoMapKit/KonocoMapKit.h>

@interface KonocoMapWindowController : NSWindowController <MapViewDelegateProtocol> {
	IBOutlet KonocoMapView *mapView;
    
    BOOL inFullScreenMode;
    NSRect normalFrame;
    NSUInteger normalStyleMask;

    BOOL inEditMode;
}

#pragma mark -
#pragma mark Actions

- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (IBAction)toggleFullscreen:(id)sender;
- (IBAction)toggleHeatMap:(id)sender;

#pragma mark -
#pragma mark Zoom, Center & Region

@property (nonatomic, assign) CGFloat zoom;
@property (nonatomic, assign) CLLocationCoordinate2D center;
@property (nonatomic, assign) KonocoCoordinateRegion region;

- (void)setZoom:(CGFloat)level animated:(BOOL)animated;
- (void)setCenter:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)setRegion:(KonocoCoordinateRegion)rect animated:(BOOL)animated;

@end

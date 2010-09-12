//
//  KonocoMapView.h
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
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <KonocoMapKit/KonocoCoordinateRegion.h>

@class KonocoMapView;
@class KonocoMapLayer;
@class KonocoHeatMapLayer;
@class KonocoHeatMapSample;

#pragma mark Map View Delegate Protocol

@protocol MapViewDelegateProtocol

#pragma mark -
#pragma mark Responding to Map Region Changes

@optional
- (void)mapView:(KonocoMapView *)mapView regionWillChangeAnimated:(BOOL)animated;
- (void)mapView:(KonocoMapView *)mapView regionDidChangeAnimated:(BOOL)animated;

#pragma mark -
#pragma mark Handling General Mouse Events

@optional
- (void)mapView:(KonocoMapView *)mapView mouseClickAtCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)mapView:(KonocoMapView *)mapView mouseMovedToCoordinate:(CLLocationCoordinate2D)coordinate;

#pragma mark -
#pragma mark Handling Left Mouse Events

@optional
- (BOOL)respondToLeftMouseEventsForMapView:(KonocoMapView *)mapView;
- (void)mapView:(KonocoMapView *)mapView mouseDownAtCoordinate:(CLLocationCoordinate2D)coordinate withEvent:(NSEvent *)event;
- (void)mapView:(KonocoMapView *)mapView mouseDraggedToCoordinate:(CLLocationCoordinate2D)coordinate withEvent:(NSEvent *)event;
- (void)mapView:(KonocoMapView *)mapView mouseUpAtCoordinate:(CLLocationCoordinate2D)coordinate withEvent:(NSEvent *)event;

#pragma mark -
#pragma mark Context Menu for Coordinate

@optional
- (NSMenu *)mapView:(KonocoMapView *)mapView menuForCoordinate:(CLLocationCoordinate2D)coordinate; 

#pragma mark -
#pragma mark Heat Map Behavior

@optional
- (KonocoCoordinateRegion)mapView:(KonocoMapView *)mapView regionForSample:(KonocoHeatMapSample *)sample;
- (CFTimeInterval)mapView:(KonocoMapView *)mapView durationForSample:(KonocoHeatMapSample *)sample;
- (CGFloat)mapView:(KonocoMapView *)mapView valueForSample:(KonocoHeatMapSample *)sample;
- (NSColor *)mapView:(KonocoMapView *)mapView colorForValue:(CGFloat)value;

@end

#pragma mark -
#pragma mark -
#pragma mark Map View

@interface KonocoMapView : NSView {
    CALayer *mapLayer;
	KonocoMapLayer *baseLayer;
    KonocoHeatMapLayer *heatMap;
    NSTrackingArea *trackingArea;
    
    id delegate;
    
    BOOL mouseMoved;
    BOOL shouldHandleMouseEvents;
    BOOL inAnimatedRegionChange;
}

#pragma mark -
#pragma mark Delegate

@property (assign) id delegate;

#pragma mark -
#pragma mark Base Layer Properties

@property (assign) NSString *filterName;
@property (assign) NSDictionary *filterOptions;

#pragma mark -
#pragma mark Heat Map Properties and Methods

@property (assign) BOOL showHeatMap;
- (void)displayHeatMapSample:(KonocoHeatMapSample *)sample;
- (void)updateHeatMap;
- (NSArray *)activeHeatMapSamplesForCoordinate:(CLLocationCoordinate2D)coordinate;

#pragma mark -
#pragma mark Zoom, Center & Region

@property (nonatomic, assign) CGFloat zoom;
@property (nonatomic, assign) CLLocationCoordinate2D center;
@property (nonatomic, assign) KonocoCoordinateRegion region;

- (void)setZoom:(CGFloat)level animated:(BOOL)animated;
- (void)setCenter:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)setRegion:(KonocoCoordinateRegion)rect animated:(BOOL)animated;

@end

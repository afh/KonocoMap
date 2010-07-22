//
//  MapView.h
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

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>
#import "CoordinateConverter.h"

@class MapView;
@class MapLayer;
@class HeatMapLayer;
@class HeatMapSample;

@protocol MapViewDelegateProtocol

#pragma mark -
#pragma mark Handling User Action

@optional
- (void)mapView:(MapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate;

#pragma mark -
#pragma mark Heat Map Behavior

@optional
- (CoordinateRegion)mapView:(MapView *)mapView regionForSample:(HeatMapSample *)sample;
- (CFTimeInterval)mapView:(MapView *)mapView durationForSample:(HeatMapSample *)sample;
- (CGFloat)mapView:(MapView *)mapView valueForSample:(HeatMapSample *)sample;
- (NSColor *)mapView:(MapView *)mapView colorForValue:(CGFloat)value;
- (CAMediaTimingFunction *)mapView:(MapView *)mapView timingFunctionForSample:(HeatMapSample *)sample;

@end

@interface MapView : NSView {
    CALayer *mapLayer;
	MapLayer *baseLayer;
    HeatMapLayer *heatMap;
    NSTrackingArea *trackingArea;
    BOOL mouseMoved;
    
    id delegate;
}

#pragma mark -
#pragma mark Delegate

@property (nonatomic, retain) id delegate;

#pragma mark -
#pragma mark Base Layer Properties

@property (assign) BOOL monochromeBaseLayer;

#pragma mark -
#pragma mark Heat Map Properties

@property (assign) BOOL showHeatMap;

// TODO: Find a better name for this property
@property (retain) NSString *notificationName;

#pragma mark -
#pragma mark Zoom, Center & Region

@property (nonatomic, assign) CGFloat zoom;
@property (nonatomic, assign) CLLocationCoordinate2D center;
@property (nonatomic, assign) CoordinateRegion region;

- (void)setZoom:(CGFloat)level animated:(BOOL)animated;
- (void)setCenter:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)setRegion:(CoordinateRegion)rect animated:(BOOL)animated;

@end

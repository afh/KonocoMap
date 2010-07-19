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

typedef struct {
    CLLocationDegrees latitudeDelta;
    CLLocationDegrees longitudeDelta;
} CoordinateSpan;

typedef struct {
    CLLocationCoordinate2D center;
    CoordinateSpan span;
} CoordinateRegion;

@class MapView;
@class MapLayer;

@protocol MapViewDelegate
- (void)mapView:(MapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate;
@end

@interface MapView : NSView {
    CALayer *mapLayer;
	MapLayer *baseLayer;
    NSTrackingArea *trackingArea;
    BOOL mouseMoved;
    
    id<MapViewDelegate> delegate;
    
    void * pj_merc, * pj_wgs84;
}

#pragma mark -
#pragma mark Delegate

@property (nonatomic, retain) id<MapViewDelegate> delegate;

#pragma mark -
#pragma mark Zoom, Center & Region

@property (nonatomic, assign) CGFloat zoom;
@property (nonatomic, assign) CLLocationCoordinate2D center;
@property (nonatomic, assign) CoordinateRegion region;

- (void)setZoom:(CGFloat)level animated:(BOOL)animated;
- (void)setCenter:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)setRegion:(CoordinateRegion)rect animated:(BOOL)animated;

@end
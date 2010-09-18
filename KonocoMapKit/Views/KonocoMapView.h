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
#import <KonocoMapKit/KonocoMapAnnotation.h>
#import <KonocoMapKit/KonocoMapAnnotationView.h>

@class KonocoMapView;
@class KonocoMapLayer;
@class KonocoHeatMapLayer;
@class KonocoHeatMapSample;

@protocol MapViewDelegateProtocol

#pragma mark -
#pragma mark Responding to Map Position Changes

@optional
- (void)mapView:(KonocoMapView *)mapView regionWillChangeAnimated:(BOOL)animated;
- (void)mapView:(KonocoMapView *)mapView regionDidChangeAnimated:(BOOL)animated;

#pragma mark -
#pragma mark Handling User Action

@optional
- (void)mapView:(KonocoMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate;

#pragma mark -
#pragma mark Heat Map Behavior

@optional
- (KonocoCoordinateRegion)mapView:(KonocoMapView *)mapView regionForSample:(KonocoHeatMapSample *)sample;
- (CFTimeInterval)mapView:(KonocoMapView *)mapView durationForSample:(KonocoHeatMapSample *)sample;
- (CGFloat)mapView:(KonocoMapView *)mapView valueForSample:(KonocoHeatMapSample *)sample;
- (NSColor *)mapView:(KonocoMapView *)mapView colorForValue:(CGFloat)value;

#pragma mark -
#pragma mark Map Annotations

@optional
- (NSView<KonocoMapAnnotationView> *)mapView:(KonocoMapView *)mapView viewForAnnotation:(id<KonocoMapAnnotation>)annotation;

@end

#pragma mark -
#pragma mark -

@interface KonocoMapView : NSView {
    CALayer *mapLayer;
	KonocoMapLayer *baseLayer;
    KonocoHeatMapLayer *heatMap;
    NSTrackingArea *trackingArea;
    BOOL mouseMoved;
	NSMutableArray *_annotations;
	NSMutableArray *_annotationViews;
    
    id delegate;
}

#pragma mark -
#pragma mark Delegate

@property (assign) id delegate;

#pragma mark -
#pragma mark Base Layer Properties

@property (assign) BOOL monochromeBaseLayer;

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
- (void)addAnnotation:(id<KonocoMapAnnotation>)annotation;
- (CLLocationCoordinate2D)coordinateForPoint:(CGPoint)aPoint;

@end

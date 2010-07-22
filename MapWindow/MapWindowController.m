//
//  MapWindowController.m
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

#import "MapWindowController.h"
#import "MapView.h"
#import "HeatMapSample.h"

@implementation MapWindowController

- (id)init {
	if (self = [super initWithWindowNibName:@"MapWindow"]) {
		[self.window setExcludedFromWindowsMenu:YES];
		
		// register the controllerr as an obserrver for the properties
		// 'zoom', 'center' and 'region' of the map view
		[mapView addObserver:self
				  forKeyPath:@"zoom"
					 options:NSKeyValueObservingOptionNew
					 context:NULL];
		
		[mapView addObserver:self
				  forKeyPath:@"center"
					 options:NSKeyValueObservingOptionNew
					 context:NULL];
		
		[mapView addObserver:self
				  forKeyPath:@"region"
					 options:NSKeyValueObservingOptionNew
					 context:NULL];
        
        mapView.delegate = self;
        mapView.notificationName = @"HeatMapSample";
	}
	return self;
}

- (void)dealloc {
	[mapView removeObserver:self forKeyPath:@"zoom"];
	[mapView removeObserver:self forKeyPath:@"center"];
	[mapView removeObserver:self forKeyPath:@"region"];
	[super dealloc];
}

#pragma mark -
#pragma mark Actions

- (IBAction)zoomIn:(id)sender {
	[mapView setZoom:floor(mapView.zoom) + 1 animated:YES];
}

- (IBAction)zoomOut:(id)sender {
	[mapView setZoom:floor(mapView.zoom) - 1 animated:YES];
}

- (IBAction)toggleFullscreen:(id)sender {
	CGDisplayFadeReservationToken token;
	CGDisplayErr err;
	err = CGAcquireDisplayFadeReservation (kCGMaxDisplayReservationInterval, &token);
	if (err == kCGErrorSuccess)
	{
        // TODO: Check errors
		CGDisplayFade (token, 0.25, kCGDisplayBlendNormal, kCGDisplayBlendSolidColor, 0, 0, 0, true);
        CGDisplayCapture (kCGDirectMainDisplay);
		if ([mapView isInFullScreenMode]) {
			[mapView exitFullScreenModeWithOptions:NULL];
		} else {
			[mapView enterFullScreenMode:[mapView.window screen] withOptions:NULL];
		}
		CGDisplayFade (token, 0.25, kCGDisplayBlendSolidColor, kCGDisplayBlendNormal, 0, 0, 0, true);
		CGReleaseDisplayFadeReservation (token);
	}
}

- (IBAction)toggleHeatMap:(id)sender {
    mapView.showHeatMap = !mapView.showHeatMap;
    mapView.monochromeBaseLayer = mapView.showHeatMap;
}

#pragma mark -
#pragma mark Zoom, Center & Region

- (CGFloat)zoom {
	return mapView.zoom;
}

- (void)setZoom:(CGFloat)level {
	[mapView setZoom:level];
}

- (void)setZoom:(CGFloat)level animated:(BOOL)animated {
	[mapView setZoom:level animated:animated];
}

- (CLLocationCoordinate2D)center {
	return mapView.center;
}

- (void)setCenter:(CLLocationCoordinate2D)coordinate {
	[mapView setCenter:coordinate];
}

- (void)setCenter:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
	[mapView setCenter:coordinate animated:animated];
}

- (CoordinateRegion)region {
	return mapView.region;
}

- (void)setRegion:(CoordinateRegion)rect {
	[mapView setRegion:rect];
}

- (void)setRegion:(CoordinateRegion)rect animated:(BOOL)animated {
	[mapView setRegion:rect animated:animated];
}

#pragma mark -
#pragma mark Observing Properties of the Map View

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
	if (object == mapView) {
		if ([keyPath isEqual:@"zoom"] || [keyPath isEqual:@"center"] || [keyPath isEqual:@"region"]) {
			// OPTIMIZE: Find a better solution for the observing
			[self willChangeValueForKey:keyPath];
			[self didChangeValueForKey:keyPath];
		}
	}
}

#pragma mark -
#pragma mark MapViewDelegate

- (void)mapView:(MapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    //NSLog(@"Did Tap at Point: coordinate.latitude: %f, .longitude:%f", coordinate.latitude, coordinate.longitude);
    
    HeatMapSample *sample = [HeatMapSample new];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    sample.location = location;
    sample.data = [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:(float)rand()/RAND_MAX] forKey:@"value"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HeatMapSample"
                                                        object:sample
                                                      userInfo:nil];
    [sample release];
    [location release];
}

- (CoordinateRegion)mapView:(MapView *)mapView regionForSample:(HeatMapSample *)sample {
    
    double radius = (float)rand()/RAND_MAX * 6000 + 3000;
    
    return [[CoordinateConverter sharedCoordinateConverter]
            regionFromCoordinate:sample.location.coordinate
            withRadius:radius];
}

- (CGFloat)mapView:(MapView *)mapView valueForSample:(HeatMapSample *)sample {
    return [[sample.data objectForKey:@"value"] doubleValue];
}


@end

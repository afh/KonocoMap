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

@interface MapWindowController ()
- (void)setStyleBorderless;
- (void)setStyleNormal;
- (void)setFullScreen;
- (void)setWindowScreen;
@end


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
    if (inFullScreenMode) {
        [self setWindowScreen];
        [self performSelector:@selector(setStyleNormal) withObject:nil afterDelay:[self.window animationResizeTime:normalFrame]];
        inFullScreenMode = NO;
    } else {
        [self setStyleBorderless];
        [self performSelector:@selector(setFullScreen) withObject:nil afterDelay:[self.window animationResizeTime:[[NSScreen mainScreen] frame]]];
        inFullScreenMode = YES;
    }
}

- (IBAction)toggleHeatMap:(id)sender {
    mapView.showHeatMap = !mapView.showHeatMap;
    mapView.monochromeBaseLayer = mapView.showHeatMap;
}

#pragma mark -
#pragma mark Fullscreen

- (void)setStyleBorderless {
    [self.window setStyleMask:NSBorderlessWindowMask];
}

- (void)setStyleNormal {
    [self.window setStyleMask:NSTitledWindowMask];
}

- (void)setFullScreen {
    normalFrame = [self.window frame];
    [self.window setLevel:CGShieldingWindowLevel()];
    [self.window setFrame:[[NSScreen mainScreen] frame]
                  display:YES
                  animate:YES];
}

- (void)setWindowScreen {
    [self.window setLevel:kCGNormalWindowLevel];
    [self.window setFrame:normalFrame
                  display:YES
                  animate:YES];
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

- (void)mapView:(KonocoMapView *)aMapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    //NSLog(@"Did Tap at Point: coordinate.latitude: %f, .longitude:%f", coordinate.latitude, coordinate.longitude);
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    NSNumber *x = [NSNumber numberWithDouble:((float)rand()/RAND_MAX)];
    
    [aMapView displayHeatMapSample:[HeatMapSample sampleWithLocation:location
                                                                data:[NSDictionary dictionaryWithObject:x
                                                                                                 forKey:@"value"]]];
    [location release];
}

- (CoordinateRegion)mapView:(KonocoMapView *)mapView regionForSample:(HeatMapSample *)sample {
    
    double radius = (float)rand()/RAND_MAX * 6000 + 3000;
    
    return [[CoordinateConverter sharedCoordinateConverter]
            regionFromCoordinate:sample.location.coordinate
            withRadius:radius];
}

- (CGFloat)mapView:(KonocoMapView *)mapView valueForSample:(HeatMapSample *)sample {
    return [[sample.data objectForKey:@"value"] doubleValue];
}


@end

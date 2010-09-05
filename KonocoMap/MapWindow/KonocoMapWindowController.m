//
//  KonocoMapWindowController.m
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

#import "KonocoMapWindowController.h"

@interface KonocoMapWindowController ()
- (void)setStyleBorderless;
- (void)setStyleNormal;
- (void)setFullScreen;
- (void)setWindowScreen;
@end


@implementation KonocoMapWindowController

- (id)init {
	if (self = [super initWithWindowNibName:@"KonocoMapWindow"]) {
		[self.window setExcludedFromWindowsMenu:YES];
        mapView.delegate = self;
	}
	return self;
}

- (void)dealloc {
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
        [self performSelector:@selector(setStyleNormal) 
                   withObject:nil
                   afterDelay:[self.window animationResizeTime:normalFrame]];
        inFullScreenMode = NO;
    } else {
        [self setStyleBorderless];
        [self performSelector:@selector(setFullScreen)
                   withObject:nil
                   afterDelay:[self.window animationResizeTime:[[NSScreen mainScreen] frame]]];
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
    normalStyleMask = [self.window styleMask];
    [self.window setStyleMask:NSBorderlessWindowMask];
}

- (void)setStyleNormal {
    [self.window setStyleMask:normalStyleMask];
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

- (KonocoCoordinateRegion)region {
	return mapView.region;
}

- (void)setRegion:(KonocoCoordinateRegion)rect {
	[mapView setRegion:rect];
}

- (void)setRegion:(KonocoCoordinateRegion)rect animated:(BOOL)animated {
	[mapView setRegion:rect animated:animated];
}

#pragma mark -
#pragma mark MapViewDelegate

- (void)mapView:(KonocoMapView *)aMapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    //NSLog(@"Did Tap at Point: coordinate.latitude: %f, .longitude:%f", coordinate.latitude, coordinate.longitude);
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    NSNumber *x = [NSNumber numberWithDouble:((float)rand()/RAND_MAX)];
    
    [aMapView displayHeatMapSample:[KonocoHeatMapSample sampleWithLocation:location
                                                                      data:[NSDictionary dictionaryWithObject:x
                                                                                                       forKey:@"value"]]];
    [location release];
}

- (KonocoCoordinateRegion)mapView:(KonocoMapView *)mapView regionForSample:(KonocoHeatMapSample *)sample {
    
    double radius = (float)rand()/RAND_MAX * 6000 + 3000;
    
    return [[KonocoCoordinateConverter sharedCoordinateConverter]
            regionFromCoordinate:sample.location.coordinate
            withRadius:radius];
}

- (CGFloat)mapView:(KonocoMapView *)mapView valueForSample:(KonocoHeatMapSample *)sample {
    return [[sample.data objectForKey:@"value"] doubleValue];
}


@end

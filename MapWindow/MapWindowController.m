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
		err = CGDisplayFade (token, 0.25, kCGDisplayBlendNormal, kCGDisplayBlendSolidColor, 0, 0, 0, true);
		err = CGDisplayCapture (kCGDirectMainDisplay);
		if ([mapView isInFullScreenMode]) {
			[mapView exitFullScreenModeWithOptions:NULL];
		} else {
			[mapView enterFullScreenMode:[mapView.window screen] withOptions:NULL];
		}
		err = CGDisplayFade (token, 0.25, kCGDisplayBlendSolidColor, kCGDisplayBlendNormal, 0, 0, 0, true);
		err = CGReleaseDisplayFadeReservation (token);
	}
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

- (CGPoint)center {
	return mapView.center;
}

- (void)setCenter:(CGPoint)point {
	[mapView setCenter:point];
}

- (void)setCenter:(CGPoint)point animated:(BOOL)animated {
	[mapView setCenter:point animated:animated];
}

- (CGRect)region {
	return mapView.region;
}

- (void)setRegion:(CGRect)rect {
	[mapView setRegion:rect];
}

- (void)setRegion:(CGRect)rect animated:(BOOL)animated {
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

@end

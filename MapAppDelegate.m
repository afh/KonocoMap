//
//  MapAppDelegate.m
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

#import "MapAppDelegate.h"

// controller
#import "MapWindowController.h"
#import "NavigationPanelController.h"
#import "PreferenceController.h"
#import <proj_api.h>

@implementation MapAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = 1;
    locationManager.desiredAccuracy = 1;
    [locationManager startUpdatingLocation];
    
	[self showMapWindow:self];
    mapWindowController.zoom = 2;
}

- (void)dealloc {
    [locationManager release];
    [super dealloc];
}

#pragma mark -
#pragma mark Actions

- (IBAction)showMapWindow:(id)sender {
	if (!mapWindowController) {
		mapWindowController = [MapWindowController new];
		[mapWindowController addObserver:self
							  forKeyPath:@"region"
								 options:NSKeyValueObservingOptionNew
								 context:NULL];
	}
	[mapWindowController showWindow:self];
	[mapWindowController.window makeKeyAndOrderFront:nil];
}

- (IBAction)showNavigation:(id)sender {
	if (!navigationPanelController) {
		navigationPanelController = [NavigationPanelController new];
		if (mapWindowController) {
			[navigationPanelController setRegion:mapWindowController.region];
		}
	}
	[navigationPanelController showWindow:self];
}

- (IBAction)showPreference:(id)sender {
	if (!preferenceController) {
		preferenceController = [PreferenceController new];
	}
	[preferenceController showWindow:self];
}

- (IBAction)zoomIn:(id)sender {
	if (mapWindowController) {
		[mapWindowController zoomIn:self];
	}
}

- (IBAction)zoomOut:(id)sender {
	if (mapWindowController) {
		[mapWindowController zoomOut:self];
	}
}

- (IBAction)toggleFullscreen:(id)sender {
	if (mapWindowController) {
		[mapWindowController toggleFullscreen:self];
	}
}

#pragma mark -
#pragma mark Location Manager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"Location manager did fail with error: %@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    //
    // OPTIMIZE: Replace this solution by a more general one.
    //
    
    
    NSLog(@"Location manager did update location: %@", newLocation);
    
    projPJ pj_merc, pj_latlong;
    double x, y;
    
    x = newLocation.coordinate.longitude * DEG_TO_RAD;
    y = newLocation.coordinate.latitude * DEG_TO_RAD;
    
    if (0 == (pj_merc = pj_init_plus("+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"))) {
        NSLog(@"Could not create a marcator projector: %s", pj_strerrno(pj_errno));
    }
    
    if (0 == (pj_latlong = pj_init_plus("+proj=latlong +ellps=WGS84"))) {
        NSLog(@"Could not create a wgs84 projector: %s", pj_strerrno(pj_errno));
    }
    
    if (pj_transform(pj_latlong, pj_merc, 1, 1, &x, &y, NULL)) {
        NSLog(@"x:%f, y:%f", x, y);
        NSLog(@"Could not transform coordinate from wgs84 to mercator: %s", pj_strerrno(pj_errno));
    }

    x = (x + 20037508.342789) / (20037508.342789 * 2.0);
    y = (y + 20037508.342789) / (20037508.342789 * 2.0);

    pj_free(pj_merc);
    pj_free(pj_latlong);
    
    [mapWindowController setCenter:CGPointMake(x, y) animated:YES];
    [mapWindowController setZoom:12 animated:YES];
}

#pragma mark -
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
	if (object == mapWindowController) {
		if ([keyPath isEqual:@"region"]) {
			if (navigationPanelController) {
				[navigationPanelController setRegion:mapWindowController.region];
			}
		}
	}
}

@end

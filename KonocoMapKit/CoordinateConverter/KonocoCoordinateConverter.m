//
//  CoordinateConverter.m
//  MapKit
//
//  Created by Tobias Kräntzer on 22.07.10.
//  Copyright 2010 Konoco, Fraunhofer ISST. All rights reserved.
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
//

#import "KonocoCoordinateConverter.h"
#import <proj_api.h>

static KonocoCoordinateConverter *sharedCoordinateConverter = nil;

static CGFloat WGS84EarthRadius(CGFloat lat);

@implementation KonocoCoordinateConverter

#pragma mark -
#pragma mark Shared Converter

+ (KonocoCoordinateConverter *)sharedCoordinateConverter {
    @synchronized (sharedCoordinateConverter) {
        if (sharedCoordinateConverter == nil) {
            sharedCoordinateConverter = [[super allocWithZone:NULL] init];
        }
        return sharedCoordinateConverter;
    }
}

#pragma mark -
#pragma mark Initialization and Deallocation

-(id)init {
	if (self = [super init]) {
        
        if (0 == (pj_merc = pj_init_plus("+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"))) {
            NSLog(@"Could not create marcator projector: %s", pj_strerrno(pj_errno));
        }
        
        if (0 == (pj_wgs84 = pj_init_plus("+proj=latlong +ellps=WGS84"))) {
            NSLog(@"Could not create wgs84 projector: %s", pj_strerrno(pj_errno));
        }
        
        // TODO: Better error handling
        assert(pj_merc);
        assert(pj_wgs84);
	}
	return self;
}

- (void)dealloc {
    pj_free(pj_merc);
    pj_free(pj_wgs84);
    [super dealloc];
}

#pragma mark -
#pragma mark Coordinate Converter

- (CLLocationCoordinate2D)coordinateFromPoint:(CGPoint)point {
    double x, y;
    x = point.x;
    y = point.y;
    
    x = x * 20037508.342789 * 2 - 20037508.342789;
    y = y * 20037508.342789 * 2 - 20037508.342789;
    
    @synchronized (self) {
        // OPTIMIZE: Find out if this function is thread-safe.
        if (pj_transform(pj_merc, pj_wgs84, 1, 1, &x, &y, NULL)) {
            NSLog(@"x:%f, y:%f", x, y);
            NSLog(@"Could not transform point from mercator to wgs84: %s", pj_strerrno(pj_errno));
        }
    }
    
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = x * RAD_TO_DEG;
    coordinate.latitude = y * RAD_TO_DEG;
    return coordinate;
}

- (CGPoint)pointFromCoordinate:(CLLocationCoordinate2D)coordinate {
    double x, y;
    x = coordinate.longitude * DEG_TO_RAD;
    y = coordinate.latitude * DEG_TO_RAD;
    
    @synchronized (self) {
        // OPTIMIZE: Find out if this function is thread-safe.
        if (pj_transform(pj_wgs84, pj_merc, 1, 1, &x, &y, NULL)) {
            NSLog(@"x:%f, y:%f", x, y);
            NSLog(@"Could not transform coordinate from wgs84 to mercator: %s", pj_strerrno(pj_errno));
        }
    }
    
    x = (x + 20037508.342789) / (20037508.342789 * 2.0);
    y = (y + 20037508.342789) / (20037508.342789 * 2.0);
    
    return CGPointMake(x, y);
}

- (KonocoCoordinateRegion)regionFromRect:(CGRect)rect {
    KonocoCoordinateRegion result;
    
    CLLocationCoordinate2D lowerLeft = [self coordinateFromPoint:rect.origin];
    CLLocationCoordinate2D upperRight = [self coordinateFromPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];
    
    result.center.longitude = (upperRight.longitude + lowerLeft.longitude) / 2;
    result.center.latitude = (upperRight.latitude + lowerLeft.latitude) / 2;
    result.span.longitudeDelta = upperRight.longitude - lowerLeft.longitude;
    result.span.latitudeDelta = upperRight.latitude - lowerLeft.latitude;
    
    return result;
}

- (CGRect)rectFromRegion:(KonocoCoordinateRegion)region {
    CLLocationCoordinate2D lowerLeftC;
    lowerLeftC.longitude = region.center.longitude - region.span.longitudeDelta / 2;
    lowerLeftC.latitude = region.center.latitude - region.span.latitudeDelta / 2;
    
    CLLocationCoordinate2D upperRightC;
    upperRightC.longitude = region.center.longitude + region.span.longitudeDelta / 2;
    upperRightC.latitude = region.center.latitude + region.span.latitudeDelta / 2;
    
    CGPoint lowerLeft = [self pointFromCoordinate:lowerLeftC];
    CGPoint upperRight = [self pointFromCoordinate:upperRightC];
    
    return CGRectMake(lowerLeft.x, lowerLeft.y, upperRight.x - lowerLeft.x, upperRight.y - lowerLeft.y);
}

- (KonocoCoordinateRegion)regionFromCoordinate:(CLLocationCoordinate2D)coordinate withRadius:(CGFloat)aRadius {
    KonocoCoordinateRegion result;
    result.center = coordinate;
    
    double lat = DEG_TO_RAD * coordinate.latitude;
    
    CGFloat radius = WGS84EarthRadius(lat);
    CGFloat pradius = radius * cos(lat);
    
    result.span.longitudeDelta = RAD_TO_DEG * 2 * aRadius / pradius;
    result.span.latitudeDelta = RAD_TO_DEG * 2 * aRadius / radius;
    
    return result;
}

#pragma mark -
#pragma mark Stuff to make this Class a Singelton

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedCoordinateConverter] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

- (void)release {
}

- (id)autorelease {
    return self;
}

@end

#pragma mark -
#pragma mark Internal Helper Functions

static CGFloat WGS84EarthRadius(CGFloat lat) {
    
    // http://en.wikipedia.org/wiki/Earth_radius
    
    double WGS84_a = 6378137.0;
    double WGS84_b = 6356752.3;
    
    double An, Bn, Ad, Bd;
    
    An = WGS84_a * WGS84_a * cos(lat);
    Bn = WGS84_b * WGS84_b * sin(lat);
    Ad = WGS84_a * cos(lat);
    Bd = WGS84_b * sin(lat);
    
    return sqrt( (An*An + Bn*Bn)/(Ad*Ad + Bd*Bd) );
}


//
//  MapView.m
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

#import "MapView.h"
#import "MapLayer.h"

#import <proj_api.h>


@interface MapView ()
- (void)setUp;
- (void)setUpCoordinateConverter;
- (CLLocationCoordinate2D)coordinateFromPoint:(CGPoint)point;
- (CGPoint)pointFromCoordinate:(CLLocationCoordinate2D)coordinate;
- (CoordinateRegion)regionFromRect:(CGRect)rect;
- (CGRect)rectFromRegion:(CoordinateRegion)region;
@end

@implementation MapView

@synthesize delegate;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib {
	[self setUp];
}

- (void)dealloc {
	[baseLayer release];
    [mapLayer release];
    [trackingArea release];
	[super dealloc];
}

#pragma mark -
#pragma mark Resizing

- (void)setFrame:(NSRect)frameRect {
	[super setFrame:frameRect];
	
	// TODO: Check which "attributes" where modified by this operation
	[self willChangeValueForKey:@"region"];
	[self willChangeValueForKey:@"center"];
	[self willChangeValueForKey:@"zoom"];
	
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	
	mapLayer.position = CGPointMake(self.bounds.size.width / 2,
									self.bounds.size.height / 2);
	
	CGFloat minScale = MAX(self.bounds.size.height / baseLayer.tileSize.height,
						   self.bounds.size.width / baseLayer.tileSize.width);
	
	CGAffineTransform aTransform = mapLayer.affineTransform;
	CGFloat scale = MAX(aTransform.a, minScale);
	
	aTransform = CGAffineTransformIdentity;
	aTransform = CGAffineTransformScale(aTransform, scale, scale);
	mapLayer.affineTransform = aTransform;
	
	CGFloat marginX = self.bounds.size.width / 2 / (scale * baseLayer.tileSize.width);
	CGFloat marginY = self.bounds.size.height / 2 / (scale * baseLayer.tileSize.height);
	
	mapLayer.anchorPoint = CGPointMake(MAX(MIN(mapLayer.anchorPoint.x, 1 - marginX), 0 + marginX),
									   MAX(MIN(mapLayer.anchorPoint.y, 1 - marginY), 0 + marginY));
	
	[self didChangeValueForKey:@"region"];
	[self didChangeValueForKey:@"center"];
	[self didChangeValueForKey:@"zoom"];
}

#pragma mark -
#pragma mark Zoom, Center & Region

- (CGFloat)zoom {
	CGAffineTransform aTransform = mapLayer.affineTransform;
	return log2f(aTransform.a);
}

- (void)setZoom:(CGFloat)level {
	[self setZoom:level animated:NO];
}

- (void)setZoom:(CGFloat)level animated:(BOOL)animated {
	// TODO: Check which "attributes" where modified by this operation
	[self willChangeValueForKey:@"region"];
	[self willChangeValueForKey:@"zoom"];
	
	if (!animated) {
		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];
	}
	
	
	CGFloat minScale = MAX(self.bounds.size.height / baseLayer.tileSize.height,
						   self.bounds.size.width / baseLayer.tileSize.width);
	
	CGFloat scale = MAX(powf(2, level), minScale);
	
	CGAffineTransform aTransform = CGAffineTransformIdentity;
	aTransform = CGAffineTransformScale(aTransform, scale, scale);
	mapLayer.affineTransform = aTransform;
	
	[self didChangeValueForKey:@"region"];
	[self didChangeValueForKey:@"zoom"];
}

- (CLLocationCoordinate2D)center {
	return [self coordinateFromPoint:mapLayer.anchorPoint];
}

- (void)setCenter:(CLLocationCoordinate2D)coordinate {
	[self setCenter:coordinate animated:NO];
}

- (void)setCenter:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
	// TODO: Check which "attributes" where modified by this operation
    
    CGPoint point = [self pointFromCoordinate:coordinate];
    
	[self willChangeValueForKey:@"region"];
	[self willChangeValueForKey:@"center"];
	
	if (!animated) {
		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];
	}
	
	CGFloat scale = powf(2, self.zoom);
	
	CGFloat marginX = self.bounds.size.width / 2 / (scale * baseLayer.tileSize.width);
	CGFloat marginY = self.bounds.size.height / 2 / (scale * baseLayer.tileSize.height);
	CGPoint aP = mapLayer.anchorPoint;
	mapLayer.anchorPoint = CGPointMake(MAX(MIN(point.x, 1 - marginX), 0 + marginX),
									   MAX(MIN(point.y, 1 - marginY), 0 + marginY));
	aP = mapLayer.anchorPoint;
	[self didChangeValueForKey:@"region"];
	[self didChangeValueForKey:@"center"];
}

- (CoordinateRegion)region {
	CGFloat scale = powf(2, self.zoom);
	
	CGFloat width = self.bounds.size.width / (baseLayer.tileSize.width * scale);
	CGFloat height = self.bounds.size.height / (baseLayer.tileSize.height * scale);
    
	return [self regionFromRect:CGRectMake(mapLayer.anchorPoint.x - width / 2,
                                           mapLayer.anchorPoint.y - height / 2,
                                           width,
                                           height)];
}

- (void)setRegion:(CoordinateRegion)rect {
	[self setRegion:rect animated:NO];
}

- (void)setRegion:(CoordinateRegion)rect animated:(BOOL)animated {
	// TODO: set the region
}

#pragma mark -
#pragma mark Mouse Event Handling

- (void)mouseDown:(NSEvent *)event {
    mouseMoved = NO;
}

- (void)mouseDragged:(NSEvent *)event {
    mouseMoved = YES;
    
	// TODO: Check which "attributes" where modified by this operation
	[self willChangeValueForKey:@"region"];
	[self willChangeValueForKey:@"center"];
	
	[CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
	
	CGFloat scale = powf(2, self.zoom);
	
	CGFloat deltaX = [event deltaX];
	CGFloat deltaY = [event deltaY];
	
	CGFloat marginX = self.bounds.size.width / 2 / (scale * baseLayer.tileSize.width);
	CGFloat marginY = self.bounds.size.height / 2 / (scale * baseLayer.tileSize.height);
    
    mapLayer.anchorPoint = CGPointMake(MAX(MIN(mapLayer.anchorPoint.x - deltaX / (scale * baseLayer.tileSize.width), 1 - marginX), 0 + marginX),
                                       MAX(MIN(mapLayer.anchorPoint.y + deltaY / (scale * baseLayer.tileSize.height), 1 - marginY), 0 + marginY));
	
	[self didChangeValueForKey:@"region"];
	[self didChangeValueForKey:@"center"];
}

- (void)mouseUp:(NSEvent *)event {
    if (mouseMoved == NO) {
        NSPoint event_location = [event locationInWindow];
        NSPoint local_point = [self convertPoint:event_location fromView:nil];
        NSPoint layer_point = [self.layer convertPoint:local_point toLayer:mapLayer];
        
        if (delegate) {
            [delegate mapView:self didTapAtCoordinate:[self coordinateFromPoint:CGPointMake(layer_point.x / baseLayer.tileSize.width, layer_point.y / baseLayer.tileSize.height)]];
        }
    }
}

- (void)scrollWheel:(NSEvent *)event {

    CGFloat deltaX = -[event deltaX] * 2;
	CGFloat deltaY = -[event deltaY] * 2;
    
    if (fabs(deltaX) > 0 || fabs(deltaY) > 0) {
        [self willChangeValueForKey:@"region"];
        [self willChangeValueForKey:@"center"];
        
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        
        CGFloat scale = powf(2, self.zoom);
        
        CGFloat marginX = self.bounds.size.width / 2 / (scale * baseLayer.tileSize.width);
        CGFloat marginY = self.bounds.size.height / 2 / (scale * baseLayer.tileSize.height);
        
        mapLayer.anchorPoint = CGPointMake(MAX(MIN(mapLayer.anchorPoint.x - deltaX / (scale * baseLayer.tileSize.width), 1 - marginX), 0 + marginX),
                                           MAX(MIN(mapLayer.anchorPoint.y + deltaY / (scale * baseLayer.tileSize.height), 1 - marginY), 0 + marginY));
        
        [self didChangeValueForKey:@"region"];
        [self didChangeValueForKey:@"center"];
    }
}

#pragma mark -
#pragma mark Handling Gestures

- (void)magnifyWithEvent:(NSEvent *)event {
    CGFloat magnification = [event magnification];
    [self setZoom:self.zoom + magnification animated:NO];
}

#pragma mark -
#pragma mark Tracking & Hiding Mouse Cursor

- (void)mouseMoved:(NSEvent *)theEvent {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideCursor) object:nil];
    [self performSelector:@selector(hideCursor) withObject:nil afterDelay:2];
}

- (void)hideCursor {
    [NSCursor setHiddenUntilMouseMoves:YES];
}

- (void)updateTrackingAreas {
    [self removeTrackingArea:trackingArea];
    [trackingArea release];
    trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                options:(NSTrackingMouseMoved | NSTrackingActiveInKeyWindow)
                                                  owner:self
                                               userInfo:nil];
    [self addTrackingArea:trackingArea];
}

#pragma mark -
#pragma mark Private Methods

- (void)setUp {
    [self setUpCoordinateConverter];
    
	// Enable CALayer backing
	[self setWantsLayer:YES];
    
    // set up map layer
    mapLayer = [[CALayer layer] retain];
    mapLayer.position = CGPointMake(self.bounds.size.width / 2,
                                    self.bounds.size.height / 2);
    [self.layer addSublayer:mapLayer];
	
	// Set up BaseLayer
	baseLayer = [[MapLayer layer] retain];
    baseLayer.position = CGPointMake(mapLayer.bounds.size.width / 2,
                                     mapLayer.bounds.size.height / 2);
	[mapLayer addSublayer:baseLayer];
    
    
	CGFloat scale = MAX(self.bounds.size.height / baseLayer.tileSize.height,
						self.bounds.size.width / baseLayer.tileSize.width);
	CGAffineTransform aTransform;
	aTransform = CGAffineTransformIdentity;
	aTransform = CGAffineTransformScale(aTransform, scale, scale);
	mapLayer.affineTransform = aTransform;
    
    // Set Tracking Area
    trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                options:(NSTrackingMouseMoved | NSTrackingActiveInKeyWindow)
                                                  owner:self
                                               userInfo:nil];
    [self addTrackingArea:trackingArea];
}
   
#pragma mark -
#pragma mark Coordinate Conversion

- (void)setUpCoordinateConverter {
    NSLog(@"Setup coordinate converter.");
    // set up projections
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

- (CLLocationCoordinate2D)coordinateFromPoint:(CGPoint)point {
    double x, y;
    x = point.x;
    y = point.y;
    
    x = x * 20037508.342789 * 2 - 20037508.342789;
    y = y * 20037508.342789 * 2 - 20037508.342789;
    
    if (pj_transform(pj_merc, pj_wgs84, 1, 1, &x, &y, NULL)) {
        NSLog(@"x:%f, y:%f", x, y);
        NSLog(@"Could not transform point from mercator to wgs84: %s", pj_strerrno(pj_errno));
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
    
    if (pj_transform(pj_wgs84, pj_merc, 1, 1, &x, &y, NULL)) {
        NSLog(@"x:%f, y:%f", x, y);
        NSLog(@"Could not transform coordinate from wgs84 to mercator: %s", pj_strerrno(pj_errno));
    }
    
    x = (x + 20037508.342789) / (20037508.342789 * 2.0);
    y = (y + 20037508.342789) / (20037508.342789 * 2.0);
    
    return CGPointMake(x, y);
}

- (CoordinateRegion)regionFromRect:(CGRect)rect {
    CoordinateRegion result;
    
    CLLocationCoordinate2D lowerLeft = [self coordinateFromPoint:rect.origin];
    CLLocationCoordinate2D upperRight = [self coordinateFromPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];
    
    result.center.longitude = (upperRight.longitude + lowerLeft.longitude) / 2;
    result.center.latitude = (upperRight.latitude + lowerLeft.latitude) / 2;
    result.span.longitudeDelta = upperRight.longitude - lowerLeft.longitude;
    result.span.latitudeDelta = upperRight.latitude - lowerLeft.latitude;
    
    return result;
}

- (CGRect)rectFromRegion:(CoordinateRegion)region {

}


@end

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
#import "HeatMapLayer.h"

#import "CoordinateConverter.h"


@interface MapView ()
- (void)setUp;
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
    [heatMap release];
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
	return [[CoordinateConverter sharedCoordinateConverter] coordinateFromPoint:mapLayer.anchorPoint];
}

- (void)setCenter:(CLLocationCoordinate2D)coordinate {
	[self setCenter:coordinate animated:NO];
}

- (void)setCenter:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
	// TODO: Check which "attributes" where modified by this operation
    
    CGPoint point = [[CoordinateConverter sharedCoordinateConverter] pointFromCoordinate:coordinate];
    
	[self willChangeValueForKey:@"region"];
	[self willChangeValueForKey:@"center"];
	
	if (!animated) {
		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];
	}
	
	CGFloat scale = powf(2, self.zoom);
	
	CGFloat marginX = self.bounds.size.width / 2 / (scale * baseLayer.tileSize.width);
	CGFloat marginY = self.bounds.size.height / 2 / (scale * baseLayer.tileSize.height);
    
	mapLayer.anchorPoint = CGPointMake(MAX(MIN(point.x, 1 - marginX), 0 + marginX),
									   MAX(MIN(point.y, 1 - marginY), 0 + marginY));
    
	[self didChangeValueForKey:@"region"];
	[self didChangeValueForKey:@"center"];
}

- (CoordinateRegion)region {
	CGFloat scale = powf(2, self.zoom);
	
	CGFloat width = self.bounds.size.width / (baseLayer.tileSize.width * scale);
	CGFloat height = self.bounds.size.height / (baseLayer.tileSize.height * scale);
    
	return [[CoordinateConverter sharedCoordinateConverter]
                 regionFromRect:CGRectMake(mapLayer.anchorPoint.x - width / 2,
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
            [delegate mapView:self didTapAtCoordinate:[[CoordinateConverter sharedCoordinateConverter] coordinateFromPoint:CGPointMake(layer_point.x / baseLayer.tileSize.width, layer_point.y / baseLayer.tileSize.height)]];
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
    
	// Enable CALayer backing
	[self setWantsLayer:YES];
    
    // set up map layer
    mapLayer = [[CALayer layer] retain];
    mapLayer.bounds = CGRectMake(0, 0, 256, 256);
    mapLayer.position = CGPointMake(self.bounds.size.width / 2,
                                    self.bounds.size.height / 2);
    [self.layer addSublayer:mapLayer];
	
	// Set up BaseLayer
	baseLayer = [[MapLayer layer] retain];
    baseLayer.monochrome = YES;
    baseLayer.position = CGPointMake(mapLayer.bounds.size.width / 2,
                                     mapLayer.bounds.size.height / 2);
	[mapLayer addSublayer:baseLayer];
    
    // set up heat map
    heatMap = [HeatMapLayer new];
    heatMap.notificationName = @"HeatMapSample";
    heatMap.bounds = mapLayer.bounds;
    heatMap.position = CGPointMake(mapLayer.bounds.size.width / 2,
                                   mapLayer.bounds.size.height / 2);
    [mapLayer addSublayer:heatMap];
    
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

@end

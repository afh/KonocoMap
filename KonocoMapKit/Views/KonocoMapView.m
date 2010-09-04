//
//  KonocoMapView.m
//  KonocoMap
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

#import "KonocoMapView.h"
#import "KonocoMapLayer.h"
#import "KonocoHeatMapLayer.h"
#import "KonocoHeatMapSample.h"

#import "KonocoCoordinateConverter.h"

@interface KonocoMapView ()
- (void)setUp;

#pragma mark -
#pragma mark Forward HeatMapLayer Delegate Methods

- (KonocoCoordinateRegion)regionForSample:(KonocoHeatMapSample *)sample;
- (CFTimeInterval)durationForSample:(KonocoHeatMapSample *)sample;
- (CGFloat)valueForSample:(KonocoHeatMapSample *)sample;
- (NSColor *)colorForValue:(CGFloat)value;

@end

@implementation KonocoMapView

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
#pragma mark Updating Content

- (void)setNeedsDisplay:(BOOL)flag {
    if (self.layer.sublayers == nil || [self.layer.sublayers indexOfObject:mapLayer] == NSNotFound) {
        DEBUG_LOG(@"map layer not in view layer.");
        [self.layer addSublayer:mapLayer];
    }
    [super setNeedsDisplay:flag];
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
#pragma mark Base Layer Properties

- (BOOL)monochromeBaseLayer {
    return baseLayer.monochrome;
}

- (void)setMonochromeBaseLayer:(BOOL)val {
    baseLayer.monochrome = val;
}

#pragma mark -
#pragma mark Heat Map Properties

- (void)setShowHeatMap:(BOOL)show {
    heatMap.hidden = !show;
}

- (BOOL)showHeatMap {
    return !heatMap.hidden;
}

- (void)displayHeatMapSample:(KonocoHeatMapSample *)sample {
    [heatMap displayHeatMapSample:sample];
}

- (void)updateHeatMap {
    [heatMap updateHeatMap];
}

- (NSArray *)activeHeatMapSamplesForCoordinate:(CLLocationCoordinate2D)coordinate {
    return [heatMap activeHeatMapSamplesForCoordinate:coordinate];
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
	return [[KonocoCoordinateConverter sharedCoordinateConverter] coordinateFromPoint:mapLayer.anchorPoint];
}

- (void)setCenter:(CLLocationCoordinate2D)coordinate {
	[self setCenter:coordinate animated:NO];
}

- (void)setCenter:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
	// TODO: Check which "attributes" where modified by this operation
    
    CGPoint point = [[KonocoCoordinateConverter sharedCoordinateConverter] pointFromCoordinate:coordinate];
    
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

- (KonocoCoordinateRegion)region {
	CGFloat scale = powf(2, self.zoom);
	
	CGFloat width = self.bounds.size.width / (baseLayer.tileSize.width * scale);
	CGFloat height = self.bounds.size.height / (baseLayer.tileSize.height * scale);
    
	return [[KonocoCoordinateConverter sharedCoordinateConverter]
                 regionFromRect:CGRectMake(mapLayer.anchorPoint.x - width / 2,
                                           mapLayer.anchorPoint.y - height / 2,
                                           width,
                                           height)];
}

- (void)setRegion:(KonocoCoordinateRegion)rect {
	[self setRegion:rect animated:NO];
}

- (void)setRegion:(KonocoCoordinateRegion)rect animated:(BOOL)animated {
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
        CGPoint layer_point = [self.layer convertPoint:CGPointMake(local_point.x, local_point.y) toLayer:mapLayer];
        
        if ([self.delegate respondsToSelector:@selector(mapView:didTapAtCoordinate:)]) {
            [delegate mapView:self didTapAtCoordinate:[[KonocoCoordinateConverter sharedCoordinateConverter] coordinateFromPoint:CGPointMake(layer_point.x / baseLayer.tileSize.width, layer_point.y / baseLayer.tileSize.height)]];
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
	baseLayer = [[KonocoMapLayer layer] retain];
    baseLayer.position = CGPointMake(mapLayer.bounds.size.width / 2,
                                     mapLayer.bounds.size.height / 2);
	[mapLayer addSublayer:baseLayer];
    
    // set up heat map
    heatMap = [KonocoHeatMapLayer new];
    heatMap.delegate = self;
    heatMap.bounds = mapLayer.bounds;
    heatMap.position = CGPointMake(mapLayer.bounds.size.width / 2,
                                   mapLayer.bounds.size.height / 2);
    heatMap.hidden = YES;
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

#pragma mark -
#pragma mark Forward HeatMapLayer Delegate Methods

- (KonocoCoordinateRegion)regionForSample:(KonocoHeatMapSample *)sample {
    if ([self.delegate respondsToSelector:@selector(mapView:regionForSample:)]) {
        return [self.delegate mapView:self regionForSample:sample];
    } else {
        return [[KonocoCoordinateConverter sharedCoordinateConverter]
                regionFromCoordinate:sample.location.coordinate
                withRadius:3000];
    }
}

- (CFTimeInterval)durationForSample:(KonocoHeatMapSample *)sample {
    if ([self.delegate respondsToSelector:@selector(mapView:durationForSample:)]) {
        return [self.delegate mapView:self durationForSample:sample];
    } else {
        return 60;
    }
}

- (CGFloat)valueForSample:(KonocoHeatMapSample *)sample {
    if ([self.delegate respondsToSelector:@selector(mapView:valueForSample:)]) {
        return [self.delegate mapView:self valueForSample:sample];
    } else {
        return (float)rand()/RAND_MAX;
    }
}

- (NSColor *)colorForValue:(CGFloat)value {
    if ([self.delegate respondsToSelector:@selector(mapView:colorForValue:)]) {
        return [self.delegate mapView:self colorForValue:value];
    } else {
        return [NSColor colorWithCalibratedHue:value
                                    saturation:1
                                    brightness:0.5
                                         alpha:0];
    }
}

@end
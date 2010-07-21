//
//  HeatMapLayer.m
//  Map
//
//  Created by Tobias Kräntzer on 20.07.10.
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

#import "HeatMapLayer.h"
#import "HeatMapSample.h"
#import "HeatMapCell.h"
#import "MapView.h"


@interface HeatMapLayer ()
- (void)handleHeatMapSample:(HeatMapSample *)aSample;
- (CoordinateRegion)regionForSample:(HeatMapSample *)sample;
- (CFTimeInterval)durationForSample:(HeatMapSample *)sample;
- (CAMediaTimingFunction *)timingFunctionForSample:(HeatMapSample *)sample;
- (NSColor *)colorForSample:(HeatMapSample *)sample;
@end


@implementation HeatMapLayer

@synthesize mapView;
@synthesize delegate;

- (id)init {
    if ((self = [super init]) != nil) {
        
        // set composition filter
        CIFilter *compFilter = [CIFilter filterWithName:@"CIColorBlendMode"];
        self.compositingFilter = compFilter;
        
        
        // set observer for heat map samples
        notificationObserver = [[[NSNotificationCenter defaultCenter] addObserverForName:@"HeatMapSample"
                                                                                  object:nil
                                                                                   queue:nil
                                                                              usingBlock:^(NSNotification *notification){
                                                                                  if ([[notification object] isKindOfClass:[HeatMapSample class]]) {
                                                                                      [self handleHeatMapSample:[notification object]];
                                                                                  } else {
                                                                                      NSLog(@"Received a notification with object other that HeatMapSample.");
                                                                                  }
                                                                              }] retain];
    }
    return self;
}

#pragma mark -
#pragma mark Handle Heat Map Samples

- (void)handleHeatMapSample:(HeatMapSample *)sample {
//    NSLog(@"Received HeatMapSample: %@", sample);
    
    assert(self.mapView);
    
    CoordinateRegion cellRegion = [self regionForSample:sample];
    
    CGFloat currentScale = powf(2, self.mapView.zoom);
//    NSLog(@"current scale: %f", currentScale);
    
//    NSLog(@"sample region: lat: %f, long: %f, delta lat: %f, delta long: %f",
//          cellRegion.center.latitude,
//          cellRegion.center.longitude,
//          cellRegion.span.latitudeDelta,
//          cellRegion.span.longitudeDelta);

    CGRect cellFrame = [self.mapView rectFromRegion:cellRegion];
    cellFrame = CGRectMake(cellFrame.origin.x * 256,
                           cellFrame.origin.y * 256, 
                           cellFrame.size.width * 256, 
                           cellFrame.size.height * 256);
    
//    NSLog(@"cell frame x: %f, y: %f, width: %f, height: %f",
//          cellFrame.origin.x,
//          cellFrame.origin.y,
//          cellFrame.size.width,
//          cellFrame.size.height);
    
    HeatMapCell *cell = [[HeatMapCell alloc] initWithSample:sample
                                                   duration:[self durationForSample:sample]
                                             timingFunction:[self timingFunctionForSample:sample]];
    cell.delegate = self;
    cell.frame = cellFrame;
    
    cell.bounds = CGRectMake(0,
                             0,
                             cell.bounds.size.width * currentScale,
                             cell.bounds.size.height * currentScale);
    
    CGAffineTransform cellTransform = CGAffineTransformIdentity;
	cellTransform = CGAffineTransformScale(cellTransform, 1 / currentScale, 1 / currentScale);
	cell.affineTransform = cellTransform;
    
//    NSLog(@"cell position x: %f, y: %f", cell.position.x, cell.position.y);
//    NSLog(@"cell bounds x: %f, y: %f, width: %f, height: %f",
//          cell.bounds.origin.x,
//          cell.bounds.origin.y,
//          cell.bounds.size.width,
//          cell.bounds.size.height);
    
    [cell setNeedsDisplay];
    
    [self addSublayer:cell];
    [cell release];
}

#pragma mark -
#pragma mark Custom Cell Attributes for Sample

- (CoordinateRegion)regionForSample:(HeatMapSample *)sample {
    if (self.delegate) {
        return [self.delegate regionForSample:sample];
    } else {
        return [self.mapView regionFromCoordinate:sample.location.coordinate
                                       withRadius:3000];
    }
}

- (CFTimeInterval)durationForSample:(HeatMapSample *)sample {
    if (self.delegate) {
        return [self.delegate durationForSample:sample];
    } else {
        return 20;
    }
}

- (CAMediaTimingFunction *)timingFunctionForSample:(HeatMapSample *)sample {
    if (self.delegate) {
        return [self.delegate timingFunctionForSample:sample];
    } else {
        return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    }
}

- (NSColor *)colorForSample:(HeatMapSample *)sample {
    if (self.delegate) {
        return [self.delegate colorForSample:sample];
    } else {
        return [NSColor colorWithCalibratedHue:0.5
                                    saturation:1
                                    brightness:0.5
                                         alpha:0];        
    }
}

#pragma mark -
#pragma mark Draw Smaple Cell Delegate

- (void)drawLayer:(CALayer *)layer
        inContext:(CGContextRef)ctx {
    
    if (![layer isKindOfClass:[HeatMapCell class]]) {
        NSLog(@"Expecting HeatMapCell.");
        return;
    }
    
    HeatMapCell *cell = (HeatMapCell *)layer;
    
    CGContextSetRGBStrokeColor(ctx, 1, 0, 1, 1);
    
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    
    NSColor *color = [self colorForSample:cell.sample];
    
    CGFloat components[8] = {
        [color redComponent], [color greenComponent], [color blueComponent], 1.0,   // Start color
        [color redComponent], [color greenComponent], [color blueComponent], 0.0    // End color
    };
    
    myColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, num_locations);
    
    CGPoint myStartPoint = CGPointMake(cell.bounds.size.width / 2, cell.bounds.size.height / 2);
    CGPoint myEndPoint = myStartPoint;
    CGFloat myStartRadius = 0;
    CGFloat myEndRadius = cell.bounds.size.width / 2;
    
    CGContextDrawRadialGradient(ctx,
                                myGradient,
                                myStartPoint,
                                myStartRadius,
                                myEndPoint,
                                myEndRadius,
                                kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(myGradient);
    CGColorSpaceRelease(myColorspace);
}

@end

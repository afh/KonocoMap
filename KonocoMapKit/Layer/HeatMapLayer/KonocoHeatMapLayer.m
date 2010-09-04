//
//  KonocoHeatMapLayer.m
//  KonocoMap
//
//  Created by Tobias Kräntzer on 20.07.10.
//  Copyright 2010 Fraunhofer ISST. All rights reserved.
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

#import "KonocoHeatMapLayer.h"
#import "KonocoHeatMapSample.h"
#import "KonocoHeatMapCell.h"


@interface KonocoHeatMapLayer ()
- (KonocoCoordinateRegion)regionForSample:(KonocoHeatMapSample *)sample;
- (CFTimeInterval)durationForSample:(KonocoHeatMapSample *)sample;
- (CGFloat)valueForSample:(KonocoHeatMapSample *)sample;
- (NSColor *)colorForValue:(CGFloat)value;
- (CAMediaTimingFunction *)timingFunctionForSample:(KonocoHeatMapSample *)sample;
@end


@implementation KonocoHeatMapLayer

- (id)init {
    if ((self = [super init]) != nil) {
        // set composition filter
        CIFilter *compFilter = [CIFilter filterWithName:@"CIColorBlendMode"];
        self.compositingFilter = compFilter;
    }
    return self;
}

#pragma mark -
#pragma mark Handle Heat Map Samples

- (void)displayHeatMapSample:(KonocoHeatMapSample *)sample {
    
    
    KonocoCoordinateRegion cellRegion = [self regionForSample:sample];
    CGRect cellFrame = [[KonocoCoordinateConverter sharedCoordinateConverter] rectFromRegion:cellRegion];
    cellFrame = CGRectMake(cellFrame.origin.x * self.bounds.size.width,
                           cellFrame.origin.y * self.bounds.size.height, 
                           cellFrame.size.width * self.bounds.size.width, 
                           cellFrame.size.height * self.bounds.size.height);
    
    NSTimeInterval duration = [self durationForSample:sample];
    NSTimeInterval offset =  [sample.location.timestamp timeIntervalSinceNow];
    if (duration + offset > 0) {
        KonocoHeatMapCell *cell;
        cell = [[KonocoHeatMapCell alloc] initWithSample:sample
                                          duration:duration + offset
                                    timingFunction:[self timingFunctionForSample:sample]];
        
        cell.opacity = (duration + offset) / duration;
        
        cell.delegate = self;
        cell.frame = cellFrame;
        
        CGFloat currentScale = self.superlayer.affineTransform.a;
        cell.bounds = CGRectMake(0,
                                 0,
                                 cell.bounds.size.width * currentScale,
                                 cell.bounds.size.height * currentScale);
        
        CGAffineTransform cellTransform = CGAffineTransformIdentity;
        cellTransform = CGAffineTransformScale(cellTransform, 1 / currentScale, 1 / currentScale);
        cell.affineTransform = cellTransform;
        
        [cell setNeedsDisplay];
        @synchronized (self) {
            [self addSublayer:cell];
        }
        [cell release];
    } else {
        DEBUG_LOG(@"skipping old sample (%f sec)", duration);
    }
}

- (void)updateHeatMap {
    
    NSArray *_sublayers = [NSArray arrayWithArray:self.sublayers];
    NSMutableArray *samples = [NSMutableArray array];
    
    @synchronized (self) {
        for (CALayer *layer in _sublayers) {
            if ([layer isKindOfClass:[KonocoHeatMapCell class]]) {
                [samples addObject:((KonocoHeatMapCell *)layer).sample];
                [layer removeFromSuperlayer];
            }
        }
    }
    
    for (KonocoHeatMapSample *sample in samples) {
        [self displayHeatMapSample:sample];
    }
}

- (NSArray *)activeHeatMapSamplesForCoordinate:(CLLocationCoordinate2D)coordinate {
    CGPoint point = [[KonocoCoordinateConverter sharedCoordinateConverter] pointFromCoordinate:coordinate];
    point.x = point.x * self.bounds.size.width;
    point.y = point.y * self.bounds.size.height;
    
    // OPTIMIZE: Find a better solution 
    NSArray *_sublayers = [NSArray arrayWithArray:self.sublayers];
    NSMutableArray *samples = [NSMutableArray array];
    
    @synchronized (self) {
        for (CALayer *layer in _sublayers) {
            if ([layer isKindOfClass:[KonocoHeatMapCell class]]) {
                if (CGRectContainsPoint(layer.frame, point)) {
                    [samples addObject:((KonocoHeatMapCell *)layer).sample];
                }
            }
        }
    }
    
    return samples;
}

#pragma mark -
#pragma mark Custom Cell Attributes for Sample

- (KonocoCoordinateRegion)regionForSample:(KonocoHeatMapSample *)sample {
    if ([self.delegate respondsToSelector:@selector(regionForSample:)]) {
        return [self.delegate regionForSample:sample];
    } else {
        return [[KonocoCoordinateConverter sharedCoordinateConverter]
                             regionFromCoordinate:sample.location.coordinate
                                       withRadius:3000];
    }
}

- (CFTimeInterval)durationForSample:(KonocoHeatMapSample *)sample {
    if ([self.delegate respondsToSelector:@selector(durationForSample:)]) {
        return [self.delegate durationForSample:sample];
    } else {
        return 60;
    }
}

- (CGFloat)valueForSample:(KonocoHeatMapSample *)sample {
    if ([self.delegate respondsToSelector:@selector(valueForSample:)]) {
        return [self.delegate valueForSample:sample];
    } else {
        return (float)rand()/RAND_MAX;
    }
}

- (CAMediaTimingFunction *)timingFunctionForSample:(KonocoHeatMapSample *)sample {
    return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
}

- (NSColor *)colorForValue:(CGFloat)value {
    if ([self.delegate respondsToSelector:@selector(colorForValue:)]) {
        return [self.delegate colorForValue:value];
    } else {
        return [NSColor colorWithCalibratedHue:value
                                    saturation:1
                                    brightness:0.5
                                         alpha:0];        
    }
}

#pragma mark -
#pragma mark Draw Sample Cell Delegate

- (void)drawLayer:(CALayer *)layer
        inContext:(CGContextRef)ctx {
    
    if (![layer isKindOfClass:[KonocoHeatMapCell class]]) {
        DEBUG_LOG(@"Expecting HeatMapCell.");
        return;
    }
    
    KonocoHeatMapCell *cell = (KonocoHeatMapCell *)layer;
    
    CGContextSetRGBStrokeColor(ctx, 1, 0, 1, 1);
    
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    
    NSColor *color = [self colorForValue:[self valueForSample:cell.sample]];
    
    CGFloat components[8] = {
        [color redComponent], [color greenComponent], [color blueComponent], 0.8,   // Start color
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

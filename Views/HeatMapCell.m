//
//  HeatMapCell.m
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

#import "HeatMapCell.h"
#import "HeatMapLayer.h"

@interface HeatMapCell ()
- (void)fadeOut;
@end


@implementation HeatMapCell


- (id)initWithValue:(double)aValue
           duration:(CFTimeInterval)aInterval {
    if (self = [super init]) {
        duration = aInterval;
        value = aValue;
        [self performSelector:@selector(fadeOut)];
	}
	return self;
}

- (void)fadeOut {
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
        [self performSelector:@selector(removeFromSuperlayer)];
    }];
    
    self.opacity = 0;
    
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimation.duration=duration;
    theAnimation.repeatCount=0;
    theAnimation.autoreverses=NO;
    theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    theAnimation.toValue=[NSNumber numberWithFloat:0.0];
    [self addAnimation:theAnimation forKey:@"animateOpacity"];
    
    [CATransaction commit];
}

#pragma mark -
#pragma mark Draw Cell

- (void)drawInContext:(CGContextRef)ctx {
    
    CGContextSetRGBStrokeColor(ctx, 1, 0, 1, 1);
    
    double huge = value;
    
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    
    NSColor *color = [NSColor colorWithCalibratedHue:huge
                                          saturation:1
                                          brightness:0.5
                                               alpha:0];
    
    CGFloat components[8] = {
        [color redComponent], [color greenComponent], [color blueComponent], 1.0,   // Start color
        [color redComponent], [color greenComponent], [color blueComponent], 0.0    // End color
    };
    
    myColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    myGradient = CGGradientCreateWithColorComponents(myColorspace, components, locations, num_locations);
    
    CGPoint myStartPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGPoint myEndPoint = myStartPoint;
    CGFloat myStartRadius = 0;
    CGFloat myEndRadius = self.bounds.size.width / 2;
    
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

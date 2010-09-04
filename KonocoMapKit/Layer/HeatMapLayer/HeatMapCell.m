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
#import "HeatMapSample.h"

@interface HeatMapCell ()
- (void)fadeOut;
@end


@implementation HeatMapCell

@synthesize sample;

- (id)initWithSample:(HeatMapSample *)aSample
            duration:(CFTimeInterval)aInterval
      timingFunction:(CAMediaTimingFunction *)aTimingFunction {
    if (self = [super init]) {
        sample = [aSample retain];
        duration = aInterval;
        timingFunction = [aTimingFunction retain];
        [self performSelector:@selector(fadeOut)];
	}
	return self;
}

- (void)dealloc {
    [sample release];
    [timingFunction release];
    [super dealloc];
}

- (void)fadeOut {
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
        [self performSelector:@selector(removeFromSuperlayer)];
    }];
    
    CGFloat startOpacity = self.opacity;
    self.opacity = 0;
    
    CABasicAnimation *theAnimation = [CABasicAnimation new];
    theAnimation.timingFunction = timingFunction;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimation.duration=duration;
    theAnimation.repeatCount=0;
    theAnimation.autoreverses=NO;
    theAnimation.fromValue=[NSNumber numberWithFloat:startOpacity];
    theAnimation.toValue=[NSNumber numberWithFloat:0.0];
    [self addAnimation:theAnimation forKey:@"animateOpacity"];
    
    [CATransaction commit];
}


@end

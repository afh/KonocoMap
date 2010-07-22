//
//  HeatMapLayer.h
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

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import "CoordinateConverter.h"

@class HeatMapSample;

@protocol HeatMapDelegateProtocol

@required
- (CoordinateRegion)regionForSample:(HeatMapSample *)sample;
- (CFTimeInterval)durationForSample:(HeatMapSample *)sample;
- (CGFloat)valueForSample:(HeatMapSample *)sample;

@optional
- (NSColor *)colorForValue:(CGFloat)value;
- (CAMediaTimingFunction *)timingFunctionForSample:(HeatMapSample *)sample;

@end


@interface HeatMapLayer : CALayer {
    
@private
    id notificationObserver;
    NSObject<HeatMapDelegateProtocol> *heatMapDelegate;
    
    // TODO: Find a better name for this property
    NSString *notificationName;
}

@property (assign) NSObject<HeatMapDelegateProtocol> *heatMapDelegate;
@property (retain) NSString *notificationName;

@end

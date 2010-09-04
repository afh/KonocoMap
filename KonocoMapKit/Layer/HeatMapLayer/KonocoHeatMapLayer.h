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

#import "KonocoCoordinateConverter.h"

@class KonocoHeatMapSample;

@protocol KonocoHeatMapDelegateProtocol

@required
- (KonocoCoordinateRegion)regionForSample:(KonocoHeatMapSample *)sample;
- (CFTimeInterval)durationForSample:(KonocoHeatMapSample *)sample;
- (CGFloat)valueForSample:(KonocoHeatMapSample *)sample;

@optional
- (NSColor *)colorForValue:(CGFloat)value;

@end

@interface KonocoHeatMapLayer : CALayer {
}

- (void)displayHeatMapSample:(KonocoHeatMapSample *)aSample;
- (void)updateHeatMap;
- (NSArray *)activeHeatMapSamplesForCoordinate:(CLLocationCoordinate2D)coordinate;

@end

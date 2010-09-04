//
//  KonocoHeatMapCell.h
//  KonocoMap
//
//  Created by Tobias Kräntzer on 20.07.10.
//  Copyright 2010 Fraunhofer ISST. All rights reserved.
//
//  This file is part of Konoco Map.
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

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

@class KonocoHeatMapSample;

@interface KonocoHeatMapCell : CALayer {

@private
    KonocoHeatMapSample *sample;
    CFTimeInterval duration;
    CAMediaTimingFunction *timingFunction;
}

- (id)initWithSample:(KonocoHeatMapSample *)aSample
            duration:(CFTimeInterval)aInterval
      timingFunction:(CAMediaTimingFunction *)aTimingFunction;

@property (nonatomic, readonly) KonocoHeatMapSample *sample;

@end

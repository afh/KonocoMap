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
@end


@implementation HeatMapLayer

@synthesize mapView;

- (id)init {
    if ((self = [super init]) != nil) {
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
    
    CoordinateRegion cellRegion = [self.mapView regionFromCoordinate:sample.location.coordinate
                                                          withRadius:5000];
    
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
    
    
    HeatMapCell *cell = [[HeatMapCell alloc] initWithValue:0.5 duration:10];
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


@end

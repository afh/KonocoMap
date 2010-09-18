//
//  KonocoPointOfInterest.m
//  KonocoMap
//
//  Created by Alexis Hildebrandt on 18/09/10.
//  Copyright 2010 Alexis Hildebrandt. All rights reserved.
//
//  This file is part of KonocoMap.
//	
//  KonocoMap is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//	
//  KonocoMap is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with KonocoMap.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Cocoa/Cocoa.h>
#import <KonocoMapKit/KonocoMapKit.h>

@interface KonocoPointOfInterest : NSObject <KonocoMapAnnotation> {
@private
	CLLocationCoordinate2D _coordinate;
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (id)initWithLatitude:(double)latitude longitude:(double)longitude;

@end

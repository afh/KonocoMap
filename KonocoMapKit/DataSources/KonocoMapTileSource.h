//
//  MapTileSource.h
//  Map
//
//  Created by Tobias Kräntzer on 08.04.10.
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

#import <Cocoa/Cocoa.h>

#import "KonocoTileSourceProtocol.h"


@interface KonocoMapTileSource : NSObject <KonocoTileSourceProtocol> {

}

+ (NSObject<KonocoTileSourceProtocol>*)sharedMapSource;

@property (nonatomic, readonly) NSInteger maxZoomLevel;
@property (nonatomic, readonly) CGSize tileSize;

- (NSImage *)tileWithZoom:(NSUInteger)zoom x:(NSUInteger)x y:(NSUInteger)y;

@end

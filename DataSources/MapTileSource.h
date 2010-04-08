//
//  MapTileSource.h
//  Map
//
//  Created by Tobias Kräntzer on 08.04.10.
//  Copyright 2010 Konoco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TileSourceProtocol.h"


@interface MapTileSource : NSObject <TileSourceProtocol> {

}

+ (NSObject<TileSourceProtocol>*)sharedMapSource;

@property (nonatomic, readonly) NSInteger maxZoomLevel;
@property (nonatomic, readonly) CGSize tileSize;

- (NSImage *)tileWithZoom:(NSUInteger)zoom x:(NSUInteger)x y:(NSUInteger)y;

@end

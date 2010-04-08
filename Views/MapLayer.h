//
//  MapLayer.h
//  Map
//
//  Created by Tobias Kräntzer on 07.04.10.
//  Copyright 2010 Konoco. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import "TileSourceProtocol.h"

@interface MapLayer : CATiledLayer {
	NSObject <TileSourceProtocol> *tileSource;
}

@property (nonatomic, readonly) NSObject <TileSourceProtocol> *tileSource;

- (id)initWithTileSource:(NSObject<TileSourceProtocol>*)source;

@end

//
//  MapTileSource.m
//  Map
//
//  Created by Tobias Kräntzer on 08.04.10.
//  Copyright 2010 Konoco. All rights reserved.
//

#import "MapTileSource.h"

NSObject<TileSourceProtocol> *sharedMapSource = nil;

@implementation MapTileSource

#pragma mark -
#pragma mark Init and Stuff to act as a Singleton

+ (NSObject<TileSourceProtocol>*)sharedMapSource {
	@synchronized(self) {
		if (sharedMapSource == nil) {
			[self new];
		}
	}
	return sharedMapSource;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedMapSource == nil) {
            sharedMapSource = [super allocWithZone:zone];
            return sharedMapSource;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

-(id)init {
	if (self = [super init]) {
		// do init here
	}
	return self;
}

#pragma mark -
#pragma mark Tile Source Protocol

- (NSInteger)maxZoomLevel {
	return 18;
}

- (CGSize)tileSize {
	return CGSizeMake(256, 256);
}

- (NSImage *)tileWithZoom:(NSUInteger)zoom x:(NSUInteger)x y:(NSUInteger)y {
	NSURL *tileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/%d/%d.png", @"http://tile.openstreetmap.org", zoom, x, y]];
	NSImage *tile = [[NSImage alloc] initWithContentsOfURL:tileURL];
	return [tile autorelease];
}

@end

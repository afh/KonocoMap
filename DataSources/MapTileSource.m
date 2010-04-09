//
//  MapTileSource.m
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

#import "MapTileSource.h"

NSObject<TileSourceProtocol> *sharedMapSource = nil;

@interface MapTileSource ()
@property (nonatomic, readonly) NSString *applicationSupportDirectory;
@property (nonatomic, readonly) NSString *mapCacheDirectory;
@end


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
    
    // OPTIMIZE: Find a smarter solution to build the path for the tile and its folder
    NSString *tileFolder = [self.mapCacheDirectory stringByAppendingPathComponent:[NSString pathWithComponents:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", zoom], [NSString stringWithFormat:@"%d", x], nil]]];
    NSString *localPath = [tileFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.png", y]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:localPath]) {
        NSImage *tile = [[NSImage alloc] initWithContentsOfFile:localPath];
        return [tile autorelease];
    } else {
        NSURL *tileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/%d/%d.png", @"http://tile.openstreetmap.org", zoom, x, y]];
        NSData *tileData = [NSData dataWithContentsOfURL:tileURL];
        NSError *error;
        [fileManager createDirectoryAtPath:tileFolder withIntermediateDirectories:YES attributes:nil error:&error];
        [tileData writeToFile:localPath atomically:YES];
        NSImage *tile = [[NSImage alloc] initWithData:tileData];
        return [tile autorelease];
    }
}

#pragma mark -
#pragma mark Private Methods

// TODO: Put this method in the app delegate
- (NSString *)applicationSupportDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Map"];
}

- (NSString *)mapCacheDirectory {
    return [self.applicationSupportDirectory stringByAppendingPathComponent:@"MapTileCache"];
}

@end

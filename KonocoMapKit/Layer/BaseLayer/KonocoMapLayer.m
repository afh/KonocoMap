//
//  KonocoMapLayer.m
//  KonocoMap
//
//  Created by Tobias Kräntzer on 07.04.10.
//  Copyright 2010 Konoco <http://konoco.org/> All rights reserved.
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

#import "KonocoMapLayer.h"
#import "KonocoMapTileSource.h"


@implementation KonocoMapLayer

@synthesize tileSource;
@synthesize filterName;
@synthesize filterOptions;

+ (CFTimeInterval)fadeDuration {
    return 0.25; 
}

- (id)initWithTileSource:(NSObject<KonocoTileSourceProtocol>*)source {
	if (self = [super init]) {
		tileSource = [source retain];
		
		self.bounds = CGRectMake(0,0,tileSource.tileSize.width,tileSource.tileSize.height);
        self.masksToBounds = NO;
        self.levelsOfDetail = tileSource.maxZoomLevel;
        self.levelsOfDetailBias = tileSource.maxZoomLevel;
	}
	return self;
}

- (id)init {
	return [self initWithTileSource:[KonocoMapTileSource sharedMapSource]];
}

- (void)dealloc {
	[tileSource release];
	[super dealloc];
}

#pragma mark -
#pragma mark Filter Name & Options

- (void)setFilterName:(NSString *)name {
    [filterName release];
    filterName = [name retain];
    [self setNeedsDisplay];
}

- (void)setFilterOptions:(NSDictionary *)options {
    [filterOptions release];
    filterOptions = [options retain];
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Draw Layer

- (void)drawInContext:(CGContextRef)ctx {
    
	CGRect rect = CGContextGetClipBoundingBox ( ctx );
    CGAffineTransform transform = CGContextGetCTM ( ctx	);
	
	NSUInteger zoom = log2(transform.a);
	NSUInteger x = -transform.tx / self.tileSize.width;
	NSUInteger y = pow(2, zoom) + (transform.ty / self.tileSize.height) - 1;
	
	NSImage *tile = [tileSource tileWithZoom:zoom x:x y:y];
	if (tile) {
        CIImage *image = [CIImage imageWithData:[tile TIFFRepresentation]];
        CIContext *context = [CIContext contextWithCGContext:ctx options:nil];
        CIImage *outputImage;
        if (self.filterName) {
            CIFilter *filter = [CIFilter filterWithName:self.filterName];
            if (filter) {
                [filter setDefaults];
                
                for (id key in [self.filterOptions keyEnumerator]) {
                    [filter setValue:[self.filterOptions valueForKey:key] forKey:key];
                }
                [filter setValue:image forKey:@"inputImage"];
                outputImage = [filter valueForKey:@"outputImage"];                
            } else {
                outputImage = image;
            }
        } else {
            outputImage = image;
        }
        [context drawImage:outputImage inRect:rect fromRect:CGRectMake(0, 0, 256, 256)];
	}
}

@end








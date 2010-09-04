//
//  KonocoMapLayer.m
//  KonocoMap
//
//  Created by Tobias Kräntzer on 07.04.10.
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

#import "KonocoMapLayer.h"
#import "KonocoMapTileSource.h"


@implementation KonocoMapLayer

@synthesize tileSource;
@synthesize monochrome;

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
        
        monochrome = NO;
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
#pragma mark Monochrome

- (void)setMonochrome:(BOOL)value {
    if (monochrome != value) {
        monochrome = value;
        [self setNeedsDisplay];
    }
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
        if (monochrome) {
            CIFilter *filter = [CIFilter filterWithName:@"CIColorMonochrome"];
            [filter setDefaults];
            [filter setValue:image forKey:@"inputImage"];
            [filter setValue:[CIColor colorWithRed:0.5 green:0.5 blue:0.5] forKey:@"inputColor"];
            outputImage = [filter valueForKey:@"outputImage"];
        } else {
            outputImage = image;
        }
        [context drawImage:outputImage inRect:rect fromRect:CGRectMake(0, 0, 256, 256)];
	}
}

@end

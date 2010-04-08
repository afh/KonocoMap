//
//  MapLayer.m
//  Map
//
//  Created by Tobias Kräntzer on 07.04.10.
//  Copyright 2010 Konoco. All rights reserved.
//

#import "MapLayer.h"

#import "MapTileSource.h"


@implementation MapLayer

@synthesize tileSource;

+ (CFTimeInterval)fadeDuration {
    return 0.25; 
}

- (id)initWithTileSource:(NSObject<TileSourceProtocol>*)source {
	if (self = [super init]) {
		tileSource = [source retain];
		
		self.bounds = CGRectMake(0,0,tileSource.tileSize.width,tileSource.tileSize.height);
        self.masksToBounds = NO;
        self.levelsOfDetail = 1;
        self.levelsOfDetailBias = tileSource.maxZoomLevel;
	}
	return self;
}

- (id)init {
	return [self initWithTileSource:[MapTileSource sharedMapSource]];
}

- (void)dealloc {
	[tileSource release];
	[super dealloc];
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
        NSData * imageData = [tile TIFFRepresentation];
        if(imageData)
        {
            CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData,  NULL);
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
            if (imageRef != nil) {  
                CGContextTranslateCTM(ctx, 0.0, rect.size.height);
                CGContextDrawImage(ctx, CGContextGetClipBoundingBox ( ctx ), imageRef );
                CFRelease(imageRef);
            }
            CFRelease(imageSource);
        }
	}
}

@end

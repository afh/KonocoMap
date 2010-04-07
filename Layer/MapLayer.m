//
//  MapLayer.m
//  Map
//
//  Created by Tobias Kräntzer on 07.04.10.
//  Copyright 2010 Konoco. All rights reserved.
//

#import "MapLayer.h"

@interface MapLayer ()
- (NSImage *)tileWithZoom:(NSUInteger)zoom x:(NSUInteger)x y:(NSUInteger)y;
@end


@implementation MapLayer

+ (CFTimeInterval)fadeDuration {
    return 0.25; 
}

- (id)init {
	if (self = [super init]) {
		self.bounds = CGRectMake(0,0,256,256);
        self.masksToBounds = NO;
        self.levelsOfDetail = 1;
        self.levelsOfDetailBias = 18;
	}
	return self;
}

#pragma mark -
#pragma mark Draw Layer

- (NSImage *)tileWithZoom:(NSUInteger)zoom x:(NSUInteger)x y:(NSUInteger)y {
	NSURL *tileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%d/%d/%d.png", @"http://tile.openstreetmap.org", zoom, x, y]];
	NSImage *tile = [[NSImage alloc] initWithContentsOfURL:tileURL];
	return [tile autorelease];
}

- (void)drawInContext:(CGContextRef)ctx {
	
	CGRect rect = CGContextGetClipBoundingBox ( ctx );
    CGAffineTransform transform = CGContextGetCTM ( ctx	);
	
	NSUInteger zoom = log2(transform.a);
	NSUInteger x = -transform.tx / self.tileSize.width;
	NSUInteger y = pow(2, zoom) + (transform.ty / self.tileSize.height) - 1;
	
	NSImage *tile = [self tileWithZoom:zoom x:x y:y];
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

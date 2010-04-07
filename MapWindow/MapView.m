//
//  MapView.m
//  Map
//
//  Created by Tobias Kräntzer on 07.04.10.
//  Copyright 2010 Konoco. All rights reserved.
//

#import "MapView.h"

#import "MapLayer.h"


@interface MapView ()
- (void)setUp;
@end

@implementation MapView

@synthesize zoom;
@synthesize center;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib {
	[self setUp];
}

- (void)dealloc {
	[mapLayer release];
	[super dealloc];
}

#pragma mark -
#pragma mark Resizing

- (void)setFrame:(NSRect)frameRect {
	[super setFrame:frameRect];
	
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	
	mapLayer.position = CGPointMake(self.bounds.size.width / 2,
									self.bounds.size.height / 2);
	
	CGFloat minScale = MAX(self.bounds.size.height / mapLayer.tileSize.height,
						   self.bounds.size.width / mapLayer.tileSize.width);
	
	CGAffineTransform aTransform = mapLayer.affineTransform;
	CGFloat scale = MAX(aTransform.a, minScale);
	
	aTransform = CGAffineTransformIdentity;
	aTransform = CGAffineTransformScale(aTransform, scale, scale);
	mapLayer.affineTransform = aTransform;
}

#pragma mark -
#pragma mark Zoom & Center

- (CGFloat)zoom {
	CGAffineTransform aTransform = mapLayer.affineTransform;
	return log2f(aTransform.a);
}

- (void)setZoom:(CGFloat)level {
	[self setZoom:level animated:NO];
}

- (void)setZoom:(CGFloat)level animated:(BOOL)animated {
	
	if (!animated) {
		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];
	}
	
	
	CGFloat minScale = MAX(self.bounds.size.height / mapLayer.tileSize.height,
						   self.bounds.size.width / mapLayer.tileSize.width);
	
	CGFloat scale = MAX(powf(2, level), minScale);
	
	CGAffineTransform aTransform = CGAffineTransformIdentity;
	aTransform = CGAffineTransformScale(aTransform, scale, scale);
	mapLayer.affineTransform = aTransform;
}

- (CGPoint)center {
	return mapLayer.anchorPoint;
}

- (void)setCenter:(CGPoint)point {
	[self setCenter:point animated:NO];
}

- (void)setCenter:(CGPoint)point animated:(BOOL)animated {
	
	if (!animated) {
		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];
	}
	
	CGFloat scale = powf(2, self.zoom);
	
	CGFloat marginX = self.bounds.size.width / 2 / (scale * mapLayer.tileSize.width);
	CGFloat marginY = self.bounds.size.height / 2 / (scale * mapLayer.tileSize.height);
	
	mapLayer.anchorPoint = CGPointMake(MAX(MIN(point.x, 1 - marginX), 0 + marginX),
									   MAX(MIN(point.y, 1 - marginY), 0 + marginY));
}

#pragma mark -
#pragma mark Mouse Event Handling

- (void)mouseDragged:(NSEvent *)theEvent {
	
	[CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
	
	CGFloat scale = powf(2, self.zoom);
	
	CGFloat deltaX = [theEvent deltaX];
	CGFloat deltaY = [theEvent deltaY];
	
	CGFloat marginX = self.bounds.size.width / 2 / (scale * mapLayer.tileSize.width);
	CGFloat marginY = self.bounds.size.height / 2 / (scale * mapLayer.tileSize.height);
	
    mapLayer.anchorPoint = CGPointMake(MAX(MIN(mapLayer.anchorPoint.x - deltaX / (scale * mapLayer.tileSize.width), 1 - marginX), 0 + marginX),
									   MAX(MIN(mapLayer.anchorPoint.y + deltaY / (scale * mapLayer.tileSize.height), 1 - marginY), 0 + marginY));
}

#pragma mark -
#pragma mark Private Methods

- (void)setUp {
	// Enable CALayer backing
	[self setWantsLayer:YES];
	
	// Set up BaseLayer
	mapLayer = [[MapLayer layer] retain];
	mapLayer.position = CGPointMake(self.bounds.size.width / 2,
									self.bounds.size.height / 2);
	[self.layer addSublayer:mapLayer];
	
	CGFloat scale = MAX(self.bounds.size.height / mapLayer.tileSize.height,
						self.bounds.size.width / mapLayer.tileSize.width);
	CGAffineTransform aTransform;
	aTransform = CGAffineTransformIdentity;
	aTransform = CGAffineTransformScale(aTransform, scale, scale);
	mapLayer.affineTransform = aTransform;
}

@end

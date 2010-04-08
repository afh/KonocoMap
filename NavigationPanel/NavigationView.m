//
//  NavigationView.m
//  Map
//
//  Created by Tobias Kräntzer on 07.04.10.
//  Copyright 2010 Konoco. All rights reserved.
//

#import "NavigationView.h"

#import "MapLayer.h"

@interface NavigationView ()
- (void)setUp;
@end


@implementation NavigationView

@synthesize region;

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
#pragma mark Drawing

- (void)drawRect:(NSRect)dirtyRect {
	[[NSColor whiteColor] setStroke];
	[[NSColor colorWithDeviceWhite:1 alpha:0.5] setFill];
	
	NSBezierPath* path = [NSBezierPath bezierPath];
	[path setLineWidth:1.0];
	
	[path moveToPoint:NSMakePoint(region.origin.x * self.bounds.size.width,
								  region.origin.y * self.bounds.size.height)];
	[path lineToPoint:NSMakePoint(region.origin.x * self.bounds.size.width,
								  (region.origin.y + region.size.height) * self.bounds.size.height)];
	[path lineToPoint:NSMakePoint((region.origin.x + region.size.width) * self.bounds.size.width,
								  (region.origin.y + region.size.height) * self.bounds.size.height)];
	[path lineToPoint:NSMakePoint((region.origin.x + region.size.width) * self.bounds.size.width,
								  region.origin.y * self.bounds.size.height)];
	[path closePath];
	[path stroke];
	[path fill];
}

#pragma mark -
#pragma mark Visible Rect

- (void)setRegion:(CGRect)rect {
	region = rect;
	[self setNeedsDisplay:YES];
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
	mapLayer.opacity = 0.5;
	[self.layer addSublayer:mapLayer];
	
	CGFloat scale = MAX(self.bounds.size.height / mapLayer.tileSize.height,
						self.bounds.size.width / mapLayer.tileSize.width);
	CGAffineTransform aTransform;
	aTransform = CGAffineTransformIdentity;
	aTransform = CGAffineTransformScale(aTransform, scale, scale);
	mapLayer.affineTransform = aTransform;
}

@end

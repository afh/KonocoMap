//
//  KonocoPinAnnotationView.m
//  KonocoMapKit
//
//  Created by Alexis Hildebrandt on 18/09/10.
//  Copyright 2010 Alexis Hildebrandt. All rights reserved.
//
//  This file is part of KonocoMapKit.
//	
//  KonocoMapKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//	
//  KonocoMapKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with KonocoMapKit.  If not, see <http://www.gnu.org/licenses/>.
//

#import "KonocoPinAnnotationView.h"


@implementation KonocoPinAnnotationView
@synthesize annotation = _annotation;

- (id)initWithImage:(NSImage *)image
   highlightedImage:(NSImage *)highlightedImage
		 annotation:(id<KonocoMapAnnotation>)anAnnotation
{
    self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    if (self) {
		self.annotation = anAnnotation;
		_image = [image retain];
		_highlightedImage = [highlightedImage retain];
    }
    return self;
}

- (void)dealloc
{
	self.annotation = nil;
	[pinDragTimer release];
	[_image release];
	[_highlightedImage release];
	[super dealloc];
}

- (void)drawRect:(CGRect)rect {
	NSImage *image = (isDragging) ? _highlightedImage : _image;
	[image drawAtPoint:CGPointZero
			  fromRect:CGRectMake(0, 0, image.size.width, image.size.height)
			 operation:NSCompositeSourceOver
			  fraction:1.0];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	CGPoint point = [theEvent locationInWindow];
	CGPoint lpoint = [self convertPoint:point fromView:nil];
	point.x -= lpoint.x;
	point.y -= lpoint.y;
	CLLocationCoordinate2D coord = [((KonocoMapView *)[self superview]) coordinateForPoint:point];
	_annotation.coordinate = coord;
	isDragging = NO;
	[self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	pinDragTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
													target:self
												  selector:@selector(startDrag)
												  userInfo:nil
												   repeats:NO];
}

- (void)startDrag
{
	isDragging = YES;
	pinDragTimer = nil;
	[self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	if (isDragging) {
		NSRect frame = [self frame];
		frame.origin.x += [theEvent deltaX];
		frame.origin.y -= [theEvent deltaY];
		[self setFrame:frame];
	}
	else {
		[pinDragTimer invalidate];
		pinDragTimer = nil;
		[super mouseDragged:theEvent];
	}
}

@end

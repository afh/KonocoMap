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

#import <Cocoa/Cocoa.h>
#import <KonocoMapKit/KonocoMapKit.h>


@interface KonocoPinAnnotationView : NSView <KonocoMapAnnotationView> {
	BOOL isDragging;
	NSTimer *pinDragTimer;
	NSImage *_image;
	NSImage *_highlightedImage;
	CGPoint _centerOffset;
	id<KonocoMapAnnotation> _annotation;
}
@property (nonatomic, retain) id<KonocoMapAnnotation> annotation;
@property (nonatomic, assign) CGPoint centerOffset;

- (id)initWithImage:(NSImage *)image
   highlightedImage:(NSImage *)highlightedImage
		 annotation:(id<KonocoMapAnnotation>)anAnnotation;

@end

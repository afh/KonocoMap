//
//  MapView.h
//  Map
//
//  Created by Tobias Kräntzer on 07.04.10.
//  Copyright 2010 Konoco. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MapLayer;

@interface MapView : NSView {
	MapLayer *mapLayer;
}

#pragma mark -
#pragma mark Zoom & Center

@property (nonatomic, assign) CGFloat zoom;
@property (nonatomic, assign) CGPoint center;

- (void)setZoom:(CGFloat)level animated:(BOOL)animated;
- (void)setCenter:(CGPoint)point animated:(BOOL)animated;

@end

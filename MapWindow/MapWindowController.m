//
//  MapWindowController.m
//  Map
//
//  Created by Tobias Kräntzer on 07.04.10.
//  Copyright 2010 Konoco. All rights reserved.
//

#import "MapWindowController.h"


@implementation MapWindowController

- (id)init {
	if (self = [super initWithWindowNibName:@"MapWindow"]) {
		[self.window setExcludedFromWindowsMenu:YES];
	}
	return self;
}

@end

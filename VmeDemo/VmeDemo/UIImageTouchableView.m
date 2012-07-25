//
//  UIImageTouchableView.m
//  VmeDemo
//
//  Created by user on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIImageTouchableView.h"
#import "Utility.h"
#import <QuartzCore/QuartzCore.h>

@interface UIImageTouchableView()

@end

@implementation UIImageTouchableView

@synthesize userData = _userData;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (nil == self) 
	{
        // Initialization code
		return nil;
	}
	self.backgroundColor = [UIColor clearColor];
	self.layer.backgroundColor = self.backgroundColor.CGColor;
    return self;
}


- (void) setImage:(UIImage*) image
{
	[self setImage:image forState:UIControlStateNormal];
	[self setImage:image forState:UIControlStateDisabled];
	[self setImage:image forState:UIControlStateSelected];
	[self setNeedsDisplay];
}


@end

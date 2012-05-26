//
//  UIImageTouchableView.m
//  VmeDemo
//
//  Created by user on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIImageTouchableView.h"

@interface UIImageTouchableView()

@property (strong, nonatomic) UIImageView* touchButton;

@end

@implementation UIImageTouchableView
@synthesize touchButton = _touchButton;
@synthesize userData = _userData;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (nil == self) 
	{
        // Initialization code
		return nil;
	}
	_touchButton = [[UIImageView alloc] init];
	[self addSubview:_touchButton];
	[_touchButton setFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
	[_touchButton setBackgroundColor:[UIColor lightGrayColor]];
    return self;
}

- (void) setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[_touchButton setFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
	[self setNeedsDisplay];
}

- (void) setImage:(UIImage*) image
{
	[_touchButton setImage:image];
	[self setNeedsDisplay];
}

- (UIImage*) image
{
	return [_touchButton image];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	[_touchButton drawRect:rect];
}


@end

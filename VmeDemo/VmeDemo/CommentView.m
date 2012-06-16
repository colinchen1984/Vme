//
//  CommentView.m
//  VmeDemo
//
//  Created by user on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommentView.h"
#import "ImageManager.h"
#import <QuartzCore/QuartzCore.h>
static const float avatarImageWidth = 55.0f;
static const float avatarImageHeight = avatarImageWidth;
static const float discenten = 5.0f;
@interface CommentView()
{
	BOOL isLeftDirection;
	float textLabelMaxWidth;
}
@property (strong, nonatomic) UILabel* textLabel;
@property (strong, nonatomic) UIImageView* avatarImageView;
@property (strong, nonatomic) UIImageView* backGroundImageView;
@end

@implementation CommentView
@synthesize userData = _userData;
@synthesize textLabel = _textLabel;
@synthesize avatarImageView = _avatarImageView;
@synthesize backGroundImageView = _backGroundImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (nil == self) 
	{
        return nil;
    }
	self.backgroundColor = [UIColor whiteColor];
	self->textLabelMaxWidth = frame.size.width - avatarImageWidth * 1.8f;
	_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, textLabelMaxWidth, frame.size.height)];
	_textLabel.numberOfLines = 0;
	_textLabel.lineBreakMode = UILineBreakModeCharacterWrap;
	[_textLabel setBackgroundColor:[UIColor clearColor]];
	_backGroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, avatarImageWidth, avatarImageHeight)];
	_avatarImageView.layer.borderColor = self.backgroundColor.CGColor;
	_avatarImageView.layer.borderWidth = 5.0f;
	_avatarImageView.layer.cornerRadius = 5.0f;
	[self addSubview:_backGroundImageView];
	[self addSubview:_avatarImageView];
	[self addSubview:_textLabel];
	self->isLeftDirection = NO;
	[self setPopDirection:YES];

    return self;
}

- (void) setPopDirection:(BOOL)isLeft
{
	if(isLeft == self->isLeftDirection)
	{
		return;
	}
	
	self->isLeftDirection = isLeft;
	UIImage* backImage = [[ImageManager sharedImageManager] getImageFromBundle:self->isLeftDirection ? @"leftPop.png" : @"rightPop.png" ];
	_backGroundImageView.image = [backImage stretchableImageWithLeftCapWidth:21 topCapHeight:15];

	[self setNeedsDisplay];
}

- (void) setAvatarImage:(UIImage*)avatarImage
{
	_avatarImageView.image = avatarImage;
	[self setNeedsDisplay];
}

- (void) settext:(NSString*)text
{
	_textLabel.text = text;
	CGRect frame = _textLabel.frame;
	frame.size.width = self->textLabelMaxWidth;
	[_textLabel sizeToFit];
	[self layoutSubviews];
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	_backGroundImageView.frame = CGRectMake(self->isLeftDirection ? avatarImageWidth + discenten : 0.0f, 0, _textLabel.frame.size.width + 30.0f, _textLabel.frame.size.height + 20.0f);
	_textLabel.center = _backGroundImageView.center;
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _backGroundImageView.frame.size.width + avatarImageWidth + discenten, MAX(avatarImageHeight + 20.0f, _textLabel.frame.size.height));
	_avatarImageView.center = CGPointMake(self->isLeftDirection ? avatarImageWidth / 2.0f : self.frame.size.width - avatarImageWidth / 2.0f, self.frame.size.height - avatarImageHeight / 2.0f);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

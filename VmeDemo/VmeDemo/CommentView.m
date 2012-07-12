//
//  CommentView.m
//  VmeDemo
//
//  Created by user on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommentView.h"
#import "ImageManager.h"
#import "UIImageTouchableView.h"
#import "Utility.h"
#import <QuartzCore/QuartzCore.h>
static const float avatarImageWidth = 55.0f;
static const float avatarImageHeight = avatarImageWidth;
static const float discenten = 5.0f;
static const float replyButtonSize = 10.0f;
@interface CommentView()
{
	BOOL isLeftDirection;
	float textLabelMaxWidth;
}
@property (strong, nonatomic) UILabel* textLabel;
@property (strong, nonatomic) UIImageTouchableView* avatarImageView;
@property (strong, nonatomic) UIImageTouchableView* backGroundImageView;
@end

@implementation CommentView
@synthesize userData = _userData;
@synthesize textLabel = _textLabel;
@synthesize avatarImageView = _avatarImageView;
@synthesize backGroundImageView = _backGroundImageView;
@synthesize delegate = _delegate;
@synthesize type = _type;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (nil == self) 
	{
        return nil;
    }
	self.backgroundColor = [UIColor clearColor];
	self->textLabelMaxWidth = frame.size.width - avatarImageWidth - discenten - 35.0f;
	_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, textLabelMaxWidth, frame.size.height)];
	_textLabel.numberOfLines = 0;
	_textLabel.lineBreakMode = UILineBreakModeCharacterWrap;
	_textLabel.backgroundColor = [UIColor clearColor];
	_backGroundImageView = [[UIImageTouchableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[_backGroundImageView addTarget:self action:@selector(OnReplyCommentButtonClick) forControlEvents:UIControlEventTouchDown];
	_backGroundImageView.layer.shadowRadius = 2.f;
	_backGroundImageView.layer.shadowOffset = CGSizeMake(2.f, 2.f);
	_backGroundImageView.layer.shadowOpacity = 1.f;
	_backGroundImageView.layer.shadowColor = [UIColor grayColor].CGColor;
	_avatarImageView = [[UIImageTouchableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, avatarImageWidth, avatarImageHeight)];
	[_avatarImageView addTarget:self action:@selector(OnAvatarClick) forControlEvents:UIControlEventTouchDown];
	_avatarImageView.layer.shadowRadius = 2.f;
	_avatarImageView.layer.shadowOffset = CGSizeMake(2.f, 2.f);
	_avatarImageView.layer.shadowOpacity = 1.f;
	_avatarImageView.layer.shadowColor = [UIColor grayColor].CGColor;
	
	[self addSubview:_backGroundImageView];
	[self addSubview:_textLabel];
	[self addSubview:_avatarImageView];
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
	[_backGroundImageView setImage:[backImage stretchableImageWithLeftCapWidth:21 topCapHeight:15]];

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
	_textLabel.frame = frame;
	[_textLabel sizeToFit];
	[self layoutSubviews];
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	_backGroundImageView.frame = CGRectMake(self->isLeftDirection ? avatarImageWidth + discenten : 0.0f, 0, _textLabel.frame.size.width + 30.0f, MAX(avatarImageHeight, _textLabel.frame.size.height + 20.0f));
	_textLabel.center = _backGroundImageView.center;
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _backGroundImageView.frame.size.width + avatarImageWidth + discenten, MAX(avatarImageHeight, _textLabel.frame.size.height + 20.0f));
	_avatarImageView.center = CGPointMake(self->isLeftDirection ? avatarImageWidth / 2.0f : self.frame.size.width - avatarImageWidth / 2.0f, self.frame.size.height - avatarImageHeight / 2.0f);
}

- (void) OnAvatarClick
{
	if ([_delegate respondsToSelector:@selector(OnAvatarClick:)]) 
	{
		[_delegate OnAvatarClick:self];
	}
}

- (void) OnReplyCommentButtonClick
{
	if ([_delegate respondsToSelector:@selector(OnReplyCommentButtonClick:)]) 
	{
		[_delegate OnReplyCommentButtonClick:self];
	}
}
@end

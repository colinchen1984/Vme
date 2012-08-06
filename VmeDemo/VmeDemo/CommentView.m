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
@property (strong, nonatomic) UILabel* textLabelForView;
@property (strong, nonatomic) UIImageTouchableView* avatarImageView;
@property (strong, nonatomic) UIImageView* backGroundImageView;
@property (strong, nonatomic) UIImageView* avatarback;
@end

@implementation CommentView
@synthesize userData = _userData;
@synthesize textLabelForView = _textLabelForView;
@synthesize avatarImageView = _avatarImageView;
@synthesize backGroundImageView = _backGroundImageView;
@synthesize avatarback = _avatarback;
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
	_textLabelForView = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, textLabelMaxWidth, frame.size.height)];
	_textLabelForView.numberOfLines = 0;
	_textLabelForView.lineBreakMode = UILineBreakModeCharacterWrap;
	_textLabelForView.backgroundColor = [UIColor clearColor];
	_backGroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
	_avatarImageView = [[UIImageTouchableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, avatarImageWidth, avatarImageHeight)];
	[_avatarImageView addTarget:self action:@selector(OnAvatarClick) forControlEvents:UIControlEventTouchDown];
	_avatarback = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, avatarImageWidth - 3.5f, avatarImageHeight - 3.5f)];
    _avatarback.center = _avatarImageView.center;
    _avatarback.image = [[ImageManager sharedImageManager] getImageFromBundle:@"avataback.png"];
    [self addSubview:_avatarback];
	[self addSubview:_backGroundImageView];
	[self addSubview:_textLabelForView];
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
	_textLabelForView.text = text;
	CGRect frame = _textLabelForView.frame;
	frame.size.width = self->textLabelMaxWidth;
	_textLabelForView.frame = frame;
	[_textLabelForView sizeToFit];
	[self layoutSubviews];
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	_backGroundImageView.frame = CGRectMake(self->isLeftDirection ? avatarImageWidth + discenten : 0.0f, 0, MAX(_textLabelForView.frame.size.width + 30.0f, 180.0f), MAX(avatarImageHeight, _textLabelForView.frame.size.height + 20.0f));
	_textLabelForView.center = _backGroundImageView.center;
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, _backGroundImageView.frame.size.width + avatarImageWidth + discenten, MAX(avatarImageHeight, _textLabelForView.frame.size.height + 20.0f));
    _avatarback.center = _avatarImageView.center = CGPointMake(self->isLeftDirection ? avatarImageWidth / 2.0f : self.frame.size.width - avatarImageWidth / 2.0f, self.frame.size.height - avatarImageHeight / 2.0f);
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

//
//  UIVideoView.m
//  VmeDemo
//
//  Created by user on 12-6-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIVideoView.h"
#import "TuDouSDK.h"
#import "SinaWeiBoSDK.h"
#import "UIImageTouchableView.h"
#import <QuartzCore/QuartzCore.h> 

@interface UIVideoView()
@property (strong, nonatomic) UIImageTouchableView* videoImageView;
@property (strong, nonatomic) NSMutableArray* avatarImageViewArray;
@property (strong, nonatomic) UILabel* textLable;
@end

static const float videoImageWidth = 100.0f;
static const float videoImageBeginPos = 5.0f;
static const float emptySize = 5.0f;
static const float textLableXPos = videoImageWidth + 5.0f;
static const int avatarImageViewCount = 4;
static const float avatarImageViewWidth = 47.5f;

@implementation UIVideoView
@synthesize weiBoData = _weiBoData;
@synthesize videoInfo = _videoInfo;
@synthesize videoImageView = _videoImageView;
@synthesize avatarImageViewArray = _avatarImageViewArray;
@synthesize textLable = _textLable;
@synthesize videoViewDelegate = _videoViewDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (nil == self) 
	{
		return nil;
    }
	float iW = frame.size.width - 2 * videoImageBeginPos;
	float vH = iW * (3.0f / 4.0f);
	self.backgroundColor = [UIColor whiteColor];
	_videoImageView = [[UIImageTouchableView alloc] initWithFrame:CGRectMake(videoImageBeginPos, videoImageBeginPos, iW, vH)];
	[self addSubview:_videoImageView];
	[_videoImageView addTarget:self action:@selector(OnVideoImageClick) forControlEvents:UIControlEventTouchDown];
	
	float textHight = 30.0f;
	vH += emptySize;
	_textLable = [[UILabel alloc] initWithFrame:CGRectMake(videoImageBeginPos,  vH, frame.size.width - 2 * videoImageBeginPos, textHight)];
	[self addSubview:_textLable];
	vH += textHight;
	
	_avatarImageViewArray = [[NSMutableArray alloc] initWithCapacity:avatarImageViewCount];
	float aHight = frame.size.height - vH - emptySize;
	vH += emptySize;
	
	for (int i = 0; i < avatarImageViewCount; ++i) 
	{
		UIImageTouchableView* avatarImageView = [[UIImageTouchableView alloc] initWithFrame:CGRectMake(videoImageBeginPos + (avatarImageViewWidth + emptySize) * i, vH, avatarImageViewWidth, aHight)];
		[_avatarImageViewArray addObject:avatarImageView];
		[avatarImageView addTarget:self action:@selector(OnWeiBoCommentUserAvatarClick:) forControlEvents:UIControlEventTouchDown];
	}
	
    return self;
}

-(void) UpdateView
{
	if (nil == _videoImageView) 
	{
		return;
	}
	
	UIImage* image = nil == _videoInfo.bigPic ? _videoInfo.pic : _videoInfo.bigPic;
	[_videoImageView setImage:image];
	_textLable.text = nil != _weiBoData ? _weiBoData.text : _videoInfo.title;
	if (nil == _weiBoData) 
	{
		//处理没有微博数据的情况
		return;
	}
	for (UIImageView* v in _avatarImageViewArray)
	{
		[v removeFromSuperview];
	}
	
	UIImageTouchableView* avatarView = [_avatarImageViewArray objectAtIndex:0];
	[avatarView setImage:_weiBoData.userInfo.avatarImage];
	avatarView.userData = _weiBoData.userInfo;
	[self addSubview:avatarView];
	if (nil == _weiBoData.comments) 
	{
		//处理微博没有comment的情况
		return;
	}
	
	int avatarCount = MIN(avatarImageViewCount - 1, [_weiBoData.comments count]);
	for (int i = 1; i <= avatarCount; ++i) 
	{
		avatarView = [_avatarImageViewArray objectAtIndex:i];
		SinaWeiBoComment* comment = [_weiBoData.comments objectAtIndex:i - 1];
		[self addSubview:avatarView];
		[avatarView setImage:comment.userInfo.avatarImage];
		avatarView.userData = comment.userInfo;
	}
}

- (void) OnVideoImageClick
{
	if ([_videoViewDelegate respondsToSelector:@selector(OnVideoImageClick:)])
    {
        [_videoViewDelegate OnVideoImageClick:self];
    }
}

- (void) OnWeiBoCommentUserAvatarClick:(UIImageTouchableView*)sender
{
	if ([_videoViewDelegate respondsToSelector:@selector(OnWeiBoCommentUserAvatarClick:)])
    {
        [_videoViewDelegate OnVideoImageClick:sender.userData];
    }
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

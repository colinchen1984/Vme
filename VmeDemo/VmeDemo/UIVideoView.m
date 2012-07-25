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
#import "ImageManager.h"
#import "Utility.h"
#import "UIImageTouchableView.h"
#import <QuartzCore/QuartzCore.h> 

@interface UIVideoView()
@property (strong, nonatomic) UIImageTouchableView* videoImageView;
@property (strong, nonatomic) NSMutableArray* avatarImageViewArray;
@property (strong, nonatomic) UILabel* textLable;
@property (strong, nonatomic) UIButton* share2WeiBo;
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
@synthesize share2WeiBo = _share2WeiBo;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
	[super setFrame:frame];
    if (nil == self) 
	{
		return nil;
    }
	UIImageView* back = [[UIImageView alloc] initWithImage:[[ImageManager sharedImageManager] getImageFromBundle:@"videoviewback.png"]];
	back.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
	[self addSubview:back];
	float iW = frame.size.width - 2 * videoImageBeginPos;
	float vH = iW * (3.0f / 4.0f);
	self.backgroundColor = [UIColor clearColor];
	_videoImageView = [[UIImageTouchableView alloc] initWithFrame:CGRectMake(videoImageBeginPos, videoImageBeginPos, iW, vH)];
	[self addSubview:_videoImageView];
	[_videoImageView addTarget:self action:@selector(OnVideoImageClick) forControlEvents:UIControlEventTouchDown];
	_videoImageView.layer.borderWidth = 5.0f;
	_videoImageView.layer.borderColor = [UIColor whiteColor].CGColor;
	_videoImageView.layer.cornerRadius = 5.0f;
	_videoImageView.layer.backgroundColor = [UIColor clearColor].CGColor;
	_videoImageView.backgroundColor = [UIColor clearColor];
	float textHight = 30.0f;
	vH += emptySize;
	_textLable = [[UILabel alloc] initWithFrame:CGRectMake(videoImageBeginPos,  vH, frame.size.width - 2 * videoImageBeginPos, textHight)];
	_textLable.backgroundColor = [UIColor clearColor];
	[self addSubview:_textLable];
	vH += textHight;
	
	_avatarImageViewArray = [[NSMutableArray alloc] initWithCapacity:avatarImageViewCount];
	float aHight = frame.size.height - vH - emptySize;
	vH += emptySize - 5.0f;
	
	for (int i = 0; i < avatarImageViewCount; ++i) 
	{
		UIImageTouchableView* avatarImageView = [[UIImageTouchableView alloc] initWithFrame:CGRectMake(videoImageBeginPos + (avatarImageViewWidth + emptySize) * i, vH, avatarImageViewWidth, aHight)];
		[_avatarImageViewArray addObject:avatarImageView];
		[avatarImageView addTarget:self action:@selector(OnWeiBoCommentUserAvatarClick:) forControlEvents:UIControlEventTouchDown];
	}
	frame = CGRectMake(videoImageBeginPos, vH, 0, 0);
	_share2WeiBo = [[UIButton alloc] initWithFrame:frame];
	UIImage* weiBoIcon = [[ImageManager sharedImageManager] getImageFromBundle:@"share2Sina.gif"];
	[_share2WeiBo setImage:weiBoIcon forState:UIControlStateNormal];
	frame.size = weiBoIcon.size;
	_share2WeiBo.frame = frame;
	[_share2WeiBo addTarget:self action:@selector(OnShare2SinaWeiBoClick) forControlEvents:UIControlEventTouchDown];
	[self addSubview:_share2WeiBo];
	self.layer.shadowColor = [UIColor grayColor].CGColor;
	self.layer.shadowRadius = 5.0f;
	self.layer.shadowOpacity = 1.0f;
	self.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
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
	_textLable.textColor = [UIColor whiteColor];
	_share2WeiBo.hidden = nil != _weiBoData;
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
        [_videoViewDelegate OnWeiBoCommentUserAvatarClick:sender.userData];
    }
}

- (void) OnShare2SinaWeiBoClick
{
	if ([_videoViewDelegate respondsToSelector:@selector(OnShare2SinaWeiBoClick:)])
    {
        [_videoViewDelegate OnShare2SinaWeiBoClick:self];
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

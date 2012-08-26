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
@property (strong, nonatomic) UIImageView* videoImageView;
@property (strong, nonatomic) NSMutableArray* avatarImageViewArray;
@property (strong, nonatomic) UILabel* textLable;
@property (strong, nonatomic) UIButton* share2WeiBo;
@end

static const float videoImageWidth = 240.0f;
static const float videoImageHBeginPos = 15.0f;
static const float emptySize = 10.0f;
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
	UIView* back = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 0.0f, 280.0f, 292.5)];
	[self addSubview: back];
	back.backgroundColor = [UIColor whiteColor];
	
	float vH = videoImageWidth * (3.0f / 4.0f) ;
	self.backgroundColor = [UIColor clearColor];
    float xpos = 0.5f * (frame.size.width - videoImageWidth);
	_videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xpos, videoImageHBeginPos, videoImageWidth, vH)];
	[self addSubview:_videoImageView];
	_videoImageView.backgroundColor = [UIColor clearColor];
	vH += videoImageHBeginPos;
	
	float textHight = 20.0f;
	vH += emptySize;
	_textLable = [[UILabel alloc] initWithFrame:CGRectMake(xpos,  vH, videoImageWidth, textHight)];
	_textLable.backgroundColor = [UIColor clearColor];
	[self addSubview:_textLable];
	vH += textHight;
    _textLable.textColor = [UIColor colorWithHue:55.0f / 255.0f saturation:55.0f/ 255.0f brightness:55.0f / 255.0f alpha:1.0f];
	
	_avatarImageViewArray = [[NSMutableArray alloc] initWithCapacity:avatarImageViewCount];
	vH += emptySize - 5.0f;
	
	for (int i = 0; i < avatarImageViewCount; ++i) 
	{
		UIImageTouchableView* avatarImageView = [[UIImageTouchableView alloc] initWithFrame:CGRectMake(xpos + (avatarImageViewWidth + emptySize) * i, vH, avatarImageViewWidth, avatarImageViewWidth)];
		[_avatarImageViewArray addObject:avatarImageView];
        [self addSubview:avatarImageView];
		[avatarImageView addTarget:self action:@selector(OnWeiBoCommentUserAvatarClick:) forControlEvents:UIControlEventTouchDown];
	}
	frame = CGRectMake(xpos, vH + 10.0f, 0, 0);
	_share2WeiBo = [[UIButton alloc] initWithFrame:frame];
	UIImage* weiBoIcon = [[ImageManager sharedImageManager] getImageFromBundle:@"share2Sina.gif"];
	[_share2WeiBo setImage:weiBoIcon forState:UIControlStateNormal];
	frame.size = weiBoIcon.size;
	_share2WeiBo.frame = frame;
	[_share2WeiBo addTarget:self action:@selector(OnShare2SinaWeiBoClick) forControlEvents:UIControlEventTouchDown];
	[self addSubview:_share2WeiBo];
	
    return self;
}

-(void) UpdateView
{
	if (nil == _videoImageView) 
	{
		return;
	}
	if(_videoInfo.bigPic)
	{
		_videoImageView.image = _videoInfo.bigPic;
	}
	else
	{
		_videoImageView.image = nil;
		[[ImageManager sharedImageManager] postURL2DownLoadImage:_videoInfo.bigPicURL Delegate:(id<URLImageDelegate>)self];
	}
	_textLable.text = nil != _weiBoData ? _weiBoData.text : _videoInfo.title;
	_share2WeiBo.hidden = nil != _weiBoData;
    for (UIImageView* v in _avatarImageViewArray)
	{
		v.hidden = YES;
	}
    
	if (nil == _weiBoData) 
	{
		//处理没有微博数据的情况
		return;
	}
	
	UIImageTouchableView* avatarView = [_avatarImageViewArray objectAtIndex:0];
	[avatarView setImage:_weiBoData.userInfo.avatarImage];
	avatarView.userData = _weiBoData.userInfo;
	avatarView.hidden = NO;
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
		avatarView.hidden = NO;
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

#pragma mark - image manager delegate
- (void) OnReceiveImage:(UIImage*)image ImageUrl:(NSString*)imageUrl
{
	if(_videoInfo && [imageUrl isEqualToString:_videoInfo.bigPicURL])
	{
		_videoImageView.image = _videoInfo.bigPic = image;
	}
}

@end

//
//  VideoDetailViewController.m
//  VmeDemo
//
//  Created by user on 12-5-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "TuDouSDK.h"
#import "UIImageTouchableView.h"
#import "VideoPageViewController.h"
#import "SinaWeiBoSDK.h"
#import "VideoWeiBoDataManager.h"
#import "CommentView.h"
#import "SendWeiBoView.h"

@interface VideoDetailViewController ()
{
	NSMutableArray* commentsViewArray;	
}
@property (strong, nonatomic) NSMutableArray* commentsViewArray;
@property (strong, nonatomic) UIImageTouchableView *bigPicImageView;
@property (strong, nonatomic) UIImageTouchableView *share2SinaWeibo;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bigPicIndicator;
@property (strong, nonatomic) NSString* userNickName;
@property (strong, nonatomic) VideoPageViewController* webView;
@property (strong, nonatomic) SendWeiBoView* sendWeiBoView;
@property (strong, nonatomic) CommentView* weiBoView;
@end

@implementation VideoDetailViewController
@synthesize commentsViewArray = _commentsViewArray;
@synthesize bigPicImageView = _bigPicImageView;
@synthesize share2SinaWeibo = _share2SinaWeibo;
@synthesize scrollView = _scrollView;
@synthesize bigPicIndicator = _bigPicIndicator;
@synthesize videoInfo = _videoInfo;
@synthesize userNickName = _userNickName;
@synthesize webView = _webView;
@synthesize sinaWeiBoSDK = _sinaWeiBoSDK;
@synthesize sendWeiBoView = _sendWeiBoView;
@synthesize weiBoView = _weiBoView;
#pragma mark - life cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"VideoDetailViewController" bundle:nil];
    if (nil == self) 
	{
        // Custom initialization
		return nil;
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	[_bigPicIndicator setHidesWhenStopped:YES];
	_bigPicImageView = [[UIImageTouchableView alloc] initWithFrame:CGRectMake(0.0f, 80.0f, 320.0f, 240.0f)];
	[_bigPicImageView addTarget:self action:@selector(onBigImageClicked:) forControlEvents:UIControlEventTouchDown];
	//调整sub的顺序,防止imageview遮盖了InDicator
	[_scrollView insertSubview:_bigPicImageView atIndex:0];
	
	_webView = [[VideoPageViewController alloc] init];
	_commentsViewArray = [[NSMutableArray alloc] init];
	_share2SinaWeibo = [[UIImageTouchableView alloc] init];
	UIImage* image = [[ImageManager sharedImageManager] getImageFromBundle:@"Share2Sina.gif"];
	[_share2SinaWeibo setImage:image];
	[_share2SinaWeibo setFrame:CGRectMake(20.0f, 330.0f, [image size].width - 2, [image size].height - 2)];
	[_share2SinaWeibo addTarget:self action:@selector(sendSinaWeiBo:) forControlEvents:UIControlEventTouchDown];
	[_scrollView addSubview:_share2SinaWeibo];
	_sendWeiBoView = [[SendWeiBoView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
	_weiBoView = [[CommentView alloc] initWithFrame:CGRectMake(0.0f, 320.0f, 300.0f, 0.0f)];
}

- (void)viewDidUnload
{
	_weiBoView = nil;
	_sendWeiBoView = nil;
	_bigPicImageView = nil;
	_bigPicIndicator = nil;
	_videoInfo = nil;
	_share2SinaWeibo = nil;
	_userNickName = nil;
	_scrollView = nil;
	_commentsViewArray = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[_bigPicIndicator startAnimating];
	[_bigPicImageView setImage:nil];
	[self navigationItem].title = _videoInfo.title;
	[[ImageManager sharedImageManager] postURL2DownLoadImage:_videoInfo.bigPicURL Delegate:self];
	
	//查找该视频是否已经发送过weibo,如果发送过,尝试得到该微博的评论
	SinaWeiBoData* weiBo = [[VideoWeiBoDataManager sharedVideoWeiBoDataManager] getWeiBoDataByVideoID:_videoInfo.itemCode];
	[self updateUI:weiBo];
	
}

- (void) updateUI:(SinaWeiBoData*) weiBo
{
	[self showVideoWeiBoData:weiBo];

	if (nil == weiBo) 
	{
		//该视频尚未发送过微博
		//现实微博按钮
		_share2SinaWeibo.hidden = NO;
		[self showComments:nil];
		return;
	}
	
	//显示该视频相关微博
	_share2SinaWeibo.hidden = YES;
	
	if(nil == weiBo.comments)
	{
		//该视频尚未有comment数据
		//请求comment数据
		[_sinaWeiBoSDK requireWeiBoComment:weiBo Delegate:self];
	}
	[self showComments:weiBo.comments];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) setVideoInfo:(TudouVideoInfo *)videoInfo
{
	if (videoInfo == _videoInfo) 
	{
		return;
	}
	_videoInfo = videoInfo;
	[_scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
}

- (void) showVideoWeiBoData:(SinaWeiBoData*)weiboData
{
	if(nil == weiboData)
	{
		[_weiBoView removeFromSuperview];
		_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, 480.0f);
		return;
	}
	NSRange range = [weiboData.text rangeOfString:@"http://t.cn/"];
	NSString* text = NSNotFound != range.location ? [weiboData.text substringToIndex:range.location] : weiboData.text;
	[_weiBoView settext:text];
	[_weiBoView setPopDirection:YES];
	[_weiBoView setAvatarImage:weiboData.userInfo.avatarImage];
	
	CGRect frame = _weiBoView.frame;
	_weiBoView.frame = CGRectMake(20.0f, 350.0f, 320.0f, frame.size.height);
	_weiBoView.userData = (id)weiboData;
	CGSize size = CGSizeMake(320, _scrollView.contentSize.height > 350.0f + frame.size.height ? _scrollView.contentSize.height : 350.0f + frame.size.height);
	_scrollView.contentSize = size;	
	[_scrollView addSubview:_weiBoView];
}

- (void) showComments:(NSArray*)comments
{
	for (UIView* v in _commentsViewArray) 
	{
		[v removeFromSuperview];
	}
	
	if (nil == comments) 
	{
		_scrollView.contentSize = CGSizeMake(320.0f, 480.0f);
		return;
	}
	
	if ([comments count] > [_commentsViewArray count]) 
	{
		int count = [comments count] - [_commentsViewArray count];
		for(int i = 0; i < count; ++i)
		{
			[_commentsViewArray addObject:[[CommentView alloc] initWithFrame:CGRectMake(0.0f, 320.0f, 300.0f, 0.0f)]];
		}
	}
	float h = _scrollView.contentSize.height;
	for(int i = 0; i < [comments count]; ++i)
	{
		SinaWeiBoComment* comment = [comments objectAtIndex:i];
		CommentView* commentView = [_commentsViewArray objectAtIndex:i];
		[commentView setPopDirection:0 == i % 2];
		[commentView settext:comment.text];
		[commentView setAvatarImage:comment.userInfo.avatarImage];
		CGRect frame = commentView.frame;
		commentView.frame = CGRectMake(0 == i % 2 ? 20.0f : 300.0f - frame.size.width, h, frame.size.width, frame.size.height);
		commentView.userData = (id)comment;
		h = commentView.frame.size.height + commentView.frame.origin.y + 10.0f;
		[_scrollView addSubview:commentView];
	}
	CGSize size = CGSizeMake(320, _scrollView.contentSize.height > h + 100 ? _scrollView.contentSize.height : h + 100);
	_scrollView.contentSize = size;	
}

#pragma mark - url image request delegate
- (void) OnReceiveImage:(UIImage*)image
{
	_videoInfo.bigPic = image;
	[_bigPicIndicator stopAnimating];
	_bigPicImageView.image = _videoInfo.bigPic;
}

- (void) OnReceiveError:(NSString*)imageURL
{

}

#pragma mark - big image clicked
- (void) onBigImageClicked:(id)sender
{
	_webView.videoInfo = _videoInfo;
	[self navigationItem].title = nil;
	[[self navigationController] pushViewController:_webView animated:YES];
}

- (IBAction)sendSinaWeiBo:(id)sender 
{
	_sendWeiBoView.videoInfo = _videoInfo;
	_sendWeiBoView.weiBoSDK = _sinaWeiBoSDK;
	_sendWeiBoView.weiboDelegate = self;
	[_sendWeiBoView Show:YES];
	return;
}

#pragma mark - sina weibo sdk delegate
- (void) OnReceiveSendWeiBoResult:(SinaWeiBoData*) sendResult
{

	NSString* itemCode = [sendResult.annotation objectAtIndex:0];
	[[VideoWeiBoDataManager sharedVideoWeiBoDataManager] addVideoWeiBoData:itemCode WeiBoData:sendResult];
	
	if ([itemCode isEqualToString:_videoInfo.itemCode]) 
	{
		[self updateUI:sendResult];
	}
	
}

- (void) OnReceiveCommentForWeiBo:(SinaWeiBoData*) weiBo Comments:(NSMutableArray*)comments
{
	NSString* videoID = [weiBo.annotation objectAtIndex:0];
	[self showComments:[[VideoWeiBoDataManager sharedVideoWeiBoDataManager] getWeiBoCommentsByVideoID:videoID]];
}

@end

//
//  VmeDemoViewController.m
//  VmeDemo
//
//  Created by user on 12-4-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VmeDemoViewController.h"
#import "VideoDetailViewController.h"
#import "UIImageTouchableView.h"
#import "VideoWeiBoDataManager.h"
#import "UIVideoView.h"

@interface VmeDemoViewController ()

@property (strong, nonatomic) NSMutableDictionary* videoViewDic;
@property (strong, nonatomic) NSMutableArray* videoInfosArray;
@property (strong, nonatomic) VideoDetailViewController* videoDetailInfoController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewForImage;
@property (strong, nonatomic) TuDouUserPersonalInfo* tudouPersonalInfo;
@end

@implementation VmeDemoViewController
@synthesize tudouSDK = _tudouSDK;
@synthesize videoViewDic = _videoViewDic;
@synthesize videoInfosArray = _videoInfosArray;
@synthesize tudouUserName = _tudouUserName;
@synthesize videoDetailInfoController = _videoDetailInfoController;
@synthesize indicator = _indicator;
@synthesize scrollViewForImage = _scrollViewForImage;
@synthesize tudouPersonalInfo = _tudouPersonalInfo;
@synthesize sinaWeiBoSDK = _sinaWeiBoSDK;

static const int imageCountForRow = 3;
static const int rowCountForPage = 5;
static const int imageCountForPage = rowCountForPage * imageCountForRow;
static const float imageWidth = 100.0f;
static const float xPosition[imageCountForRow] = {5.0f, 110.0f, 215.0f};
static const float imageDis = 5.0f;
static float yPosition[imageCountForRow] = {imageDis, imageDis, imageDis};
			  
#pragma mark - ui operation

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Do any additional setup after loading the view, typically from a nib.
	_videoViewDic = [[NSMutableDictionary alloc] init];
	_videoInfosArray = [[NSMutableArray alloc] init];
	self->currentVideoIndex = 0;
	self->currentPageNo = 1;
	self->totalPageCount = 0;
	self->totalVideoCount = 0;
	_scrollViewForImage.backgroundColor = [UIColor grayColor];
	_videoDetailInfoController = [[VideoDetailViewController alloc] initWithNibName:nil bundle:nil];
	_scrollViewForImage.showsVerticalScrollIndicator = NO;
	_scrollViewForImage.delegate = self;
	[_indicator startAnimating];
	[_sinaWeiBoSDK requireUserAllWeiBo:YES Delegate:self];
}

- (void)viewDidUnload
{
	_videoInfosArray = nil;
	_videoViewDic = nil;
	_videoDetailInfoController = nil;
	_scrollViewForImage = nil;
	_tudouPersonalInfo = nil;
	[self setIndicator:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[_tudouSDK requireUserPersonalInfo:self UserName:_tudouUserName];
	[_sinaWeiBoSDK requireUserPersonalInfo:self];
	self.navigationItem.title = _tudouPersonalInfo.userNickName;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - tudousdk delegate
- (void) OnReceiveUserPersonalInfo:(TuDouUserPersonalInfo*) userPersonalInfo
{
	[_tudouSDK requireUserVideoInfo:self UserName:_tudouUserName PageNo:(self->currentPageNo + 1)];
	[_tudouSDK requireUserVideoInfo:self UserName:_tudouUserName PageNo:(self->currentPageNo + 2)];
	_tudouPersonalInfo = userPersonalInfo;
	self.navigationItem.title = _tudouPersonalInfo.userNickName;
}

- (void) OnReceiveVideoInfo:(TudouVideoInfo*) videoInfo
{
	[_indicator stopAnimating];
	[_videoInfosArray addObject:videoInfo];
	const static float width = 240.0f;
	const static float height = width * (3.0f / 4.0f) + 80;
	float h = [_videoViewDic count] * (height + 25.0f)+ 25.0f;
	UIVideoView* v = [[UIVideoView alloc] initWithFrame:CGRectMake(10.0f, h, width, height)];
	v.videoInfo = videoInfo;
	SinaWeiBoData* w = [[VideoWeiBoDataManager sharedVideoWeiBoDataManager] getWeiBoDataByVideoID:videoInfo.itemCode];
	v.weiBoData = w;
	v.videoViewDelegate = self;
	[v UpdateView];
	[_videoViewDic setObject:v forKey:videoInfo.itemCode];
	
	[_scrollViewForImage addSubview:v];
	if (_scrollViewForImage.contentSize.height < h) 
	{
		CGSize size = _scrollViewForImage.contentSize;
		size.height = h;
		_scrollViewForImage.contentSize = size;
	}
}

- (void) OnReceiveUserVideoInfo:(int)pageNo PageSize:(int)PageSize PageCount:(int)pageCount VideoCount:(int)videoCount
{
	self->currentPageNo = pageNo;
	self->totalPageCount = pageCount;
	self->totalVideoCount = videoCount;	
}

- (void) OnReceiveError:(TUDOU_SDK_REQUEST_OPERATION_TYPE)operationType
{
	
}

#pragma mark - scroll view delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGPoint leftTop = scrollView.contentOffset;
	NSLog(@"offset.y = %f\theight = %f\n", leftTop.y, scrollView.contentSize.height);
	if(leftTop.y + 480 > scrollView.contentSize.height)
	{
		[_tudouSDK requireUserVideoInfo:self UserName:_tudouUserName PageNo:(self->currentPageNo + 1)];
	}
}

#pragma mark - sina weibo sdk delegat
- (void) OnReceiveUserAllWeiBo:(NSArray*) weiBoArray
{
	for (SinaWeiBoData* w in weiBoArray) 
	{
		[_sinaWeiBoSDK requireWeiBoComment:w Delegate:self];
	}
	
}

- (void) OnReceiveCommentForWeiBo:(SinaWeiBoData*) weiBo Comments:(NSMutableArray*)comments
{
	UIVideoView* v = [_videoViewDic objectForKey:[weiBo.annotation objectAtIndex:0]];
	if (nil == v) 
	{
		return;
	}
	[v UpdateView];
}

#pragma mark - UIVideoView delegate
- (void) OnVideoImageClick:(UIVideoView*)view
{
	self.navigationItem.title = nil;
	_videoDetailInfoController.videoInfo = view.videoInfo;
	_videoDetailInfoController.sinaWeiBoSDK = _sinaWeiBoSDK;
	[[self navigationController] pushViewController:_videoDetailInfoController animated:YES];
}

- (void) OnWeiBoCommentUserAvatarClick:(SinaWeiBoUserPersonalInfo*) userInfo
{

}
@end

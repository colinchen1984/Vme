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
#import "SendWeiBoView.h"
#import "Utility.h"
@interface VmeDemoViewController ()

@property (strong, nonatomic) NSMutableDictionary* videoViewDic;
@property (strong, nonatomic) NSMutableArray* videoInfosArray;
@property (strong, nonatomic) VideoDetailViewController* videoDetailInfoController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewForImage;
@property (strong, nonatomic) TuDouUserPersonalInfo* tudouPersonalInfo;
@property (weak, nonatomic) IBOutlet UITableView *tableViewForVideoPic;
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
@synthesize tableViewForVideoPic = _tableViewForVideoPic;
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
	_indicator.color = [UIColor blackColor];
	_scrollViewForImage.minimumZoomScale=0.5;
    _scrollViewForImage.maximumZoomScale=6.0;
	_scrollViewForImage.backgroundColor = GlobalBackGroundColor;
	_videoDetailInfoController = [[VideoDetailViewController alloc] initWithNibName:nil bundle:nil];
	_scrollViewForImage.showsVerticalScrollIndicator = NO;
	_scrollViewForImage.delegate = self;
	[_indicator startAnimating];
	[_sinaWeiBoSDK requireUserAllWeiBo:YES Delegate:self];
	_tableViewForVideoPic.dataSource = self;
	_tableViewForVideoPic.delegate = self;
}

- (void)viewDidUnload
{
	_videoInfosArray = nil;
	_videoViewDic = nil;
	_videoDetailInfoController = nil;
	_scrollViewForImage = nil;
	_tudouPersonalInfo = nil;
	_indicator = nil;
	_tableViewForVideoPic = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[_tudouSDK requireUserPersonalInfo:self UserName:_tudouUserName];
	[_sinaWeiBoSDK requireUserPersonalInfo:self];
	self.navigationItem.title = _tudouPersonalInfo.userNickName;
	CGRect frame = _tableViewForVideoPic.frame;
	frame.origin.x = 321.0f;
	_tableViewForVideoPic.frame = frame;
	_tableViewForVideoPic.alpha = 0.0f;
	[self UpdateVideoView];
	
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
const static float videoViewWidth = 300.0f;
const static float videoViewEmpt = 25.0f;
const static float videoViewHeigth = videoViewWidth * (3.0f / 4.0f) + 80;

- (void) OnReceiveVideoInfo:(TudouVideoInfo*) videoInfo
{
	if (nil != [_videoViewDic objectForKey:videoInfo.itemCode]) 
	{
		return;
	}
	[_indicator stopAnimating];
	[_videoInfosArray addObject:videoInfo];

	float h = 0.0f;
	if (0 != [_videoViewDic count]) 
	{
		UIVideoView* v = [_videoViewDic objectForKey:((TudouVideoInfo*)[_videoInfosArray objectAtIndex:[_videoViewDic count] - 1]).itemCode];
		h = 25.0f + v.frame.origin.y + v.frame.size.height;
	}
	else
	{
		h = 25.0f;
	}
	UIVideoView* v = [[UIVideoView alloc] initWithFrame:CGRectMake(10.0f, h, videoViewWidth, videoViewHeigth)];
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
	[_tableViewForVideoPic reloadData];
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
	if(leftTop.y + 480 > scrollView.contentSize.height)
	{
		[_tudouSDK requireUserVideoInfo:self UserName:_tudouUserName PageNo:(self->currentPageNo + 1)];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[UIView beginAnimations:nil context:nil];
	CGRect frame = _tableViewForVideoPic.frame;
	frame.origin.x = 261.0f;
	_tableViewForVideoPic.frame = frame;
	_tableViewForVideoPic.alpha = 0.9f;
	[UIView commitAnimations];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[self performSelector:@selector(HideVideoTableView) withObject:nil afterDelay:3.0f];
}

- (void)HideVideoTableView
{
	[UIView beginAnimations:nil context:nil];
	CGRect frame = _tableViewForVideoPic.frame;
	frame.origin.x = 321.0f;
	_tableViewForVideoPic.frame = frame;
	_tableViewForVideoPic.alpha = 0.0f;
	[UIView commitAnimations];	
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
	NSInteger index = (int)targetContentOffset->y % ((int)videoViewHeigth);
	if (0 == index || index >= [_videoInfosArray count]) 
	{
		return;
	}
	
	UIVideoView* v = [_videoViewDic objectForKey:((TudouVideoInfo*)[_videoInfosArray objectAtIndex:index]).itemCode];
	if(nil == v)
	{
		return;
	}
	
	CGRect frame = v.frame;
	targetContentOffset->y = frame.origin.y - (480.0f - frame.size.height);
	return;
}

- (void) UpdateVideoView
{
	NSDictionary* weiBoData = [[VideoWeiBoDataManager sharedVideoWeiBoDataManager] getAllWeiBoData];
	int vCount = _videoViewDic.count;
	int c = 0;
	for (SinaWeiBoData* w in [weiBoData allValues]) 
	{
		if(c == vCount)
		{
			break;
		}
		NSString* itemCode = [w.annotation objectAtIndex:0];
		UIVideoView* v = [_videoViewDic objectForKey:itemCode];
		if (nil == v 
			|| (nil != v.weiBoData && w.comments.count == v.weiBoData.comments.count)) 
		{
			continue;
		}
		++c;
		v.weiBoData = w;
		[v UpdateView];
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

- (void) OnReceiveSendWeiBoResult:(SinaWeiBoData*) sendResult
{
	UIVideoView* v = [_videoViewDic objectForKey:[sendResult.annotation objectAtIndex:0]];
	if(nil == v)
	{
		return;
	}
	v.weiBoData = sendResult;
	[v UpdateView];
}

- (void) OnReceiveCommentForWeiBo:(SinaWeiBoData*) weiBo Comments:(NSArray*)comments
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

- (void) OnShare2SinaWeiBoClick:(UIVideoView*)view
{
	[SendWeiBoView sharedSendWeiBoView].videoInfo = view.videoInfo;
	[SendWeiBoView sharedSendWeiBoView].weiBoSDK = _sinaWeiBoSDK;
	[SendWeiBoView sharedSendWeiBoView].weiboDelegate = self;
	[SendWeiBoView sharedSendWeiBoView].operationType = SINA_WEIBO_SEND_WEIBO;
	[SendWeiBoView sharedSendWeiBoView].operationData = nil;
	[[SendWeiBoView sharedSendWeiBoView] Show:YES];	
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@""];
	if(nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
	}
	TudouVideoInfo* video = ((TudouVideoInfo*)[_videoInfosArray objectAtIndex:indexPath.row]);
	cell.imageView.image = nil != video.bigPic ? video.bigPic : video.pic;
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_videoInfosArray count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	TudouVideoInfo* v = [_videoInfosArray objectAtIndex:indexPath.row];
	UIVideoView* vv = [_videoViewDic objectForKey:v.itemCode];
	CGRect frame = vv.frame;
	if (0 == indexPath.row) 
	{
		_scrollViewForImage.contentOffset = CGPointMake(0.0f, 0.0f);
		return;
	}

	_scrollViewForImage.contentOffset = CGPointMake(0.0f, frame.origin.y - (480.0f - frame.size.height- 65.0f));
	return;
}

@end

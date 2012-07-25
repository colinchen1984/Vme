//
//  VmeDemoViewController.m
//  VmeDemo
//
//  Created by user on 12-4-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VmeDemoViewController.h"
#import "VideoDetailViewController.h"
#import "VideoWeiBoDataManager.h"
#import "UIVideoView.h"
#import "SendWeiBoView.h"
#import "Utility.h"

@interface VmeDemoViewController ()

@property (strong, nonatomic) NSMutableDictionary* videoViewDic;
@property (strong, nonatomic) NSMutableArray* videoInfosArray;
@property (strong, nonatomic) VideoDetailViewController* videoDetailInfoController;
@property (weak, nonatomic) IBOutlet UITableView *videoViewTable;

@property (strong, nonatomic) TuDouUserPersonalInfo* tudouPersonalInfo;
@property (strong, nonatomic) SinaWeiBoUserPersonalInfo* sinaPersnalInfo;
@property (weak, nonatomic) IBOutlet UITableView *table4FastScroll;
@end

@implementation VmeDemoViewController
@synthesize tudouSDK = _tudouSDK;
@synthesize videoViewDic = _videoViewDic;
@synthesize videoInfosArray = _videoInfosArray;
@synthesize tudouUserName = _tudouUserName;
@synthesize videoDetailInfoController = _videoDetailInfoController;
@synthesize videoViewTable = _videoViewTable;
@synthesize tudouPersonalInfo = _tudouPersonalInfo;
@synthesize table4FastScroll = _table4FastScroll;
@synthesize sinaWeiBoSDK = _sinaWeiBoSDK;
@synthesize sinaPersnalInfo = _sinaPersnalInfo;

#pragma mark - ui operation


const static float videoViewWidth = 320.0f;
const static float videoViewHeigth = videoViewWidth * (3.0f / 4.0f) + 80;
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
	_videoDetailInfoController = [[VideoDetailViewController alloc] initWithNibName:nil bundle:nil];


	[_sinaWeiBoSDK requireUserAllWeiBo:YES Delegate:(id<SinaWeiBoSDKDelegate>)self];
	_table4FastScroll.dataSource = (id<UITableViewDataSource>)self;
	_table4FastScroll.delegate = (id<UITableViewDelegate>)self;
    _videoViewTable.dataSource = (id<UITableViewDataSource>)self;
    _videoViewTable.delegate = (id<UITableViewDelegate>)self;
	((UIScrollView*)_videoViewTable).delegate = (id<UIScrollViewDelegate>)self;
	_videoViewTable.backgroundColor = [UIColor clearColor];
	_videoViewTable.separatorStyle = NO;
	_videoViewTable.rowHeight = videoViewHeigth;
	_table4FastScroll.separatorStyle = NO;
	_table4FastScroll.backgroundColor = [UIColor clearColor];
	CGRect frame = _table4FastScroll.frame;
	frame.origin.x = 279.0f;
	_table4FastScroll.frame = frame;
	_table4FastScroll.alpha = 0.7f;
    [_tudouSDK requireUserPersonalInfo:self UserName:_tudouUserName];
    [_sinaWeiBoSDK requireUserPersonalInfo:(id<SinaWeiBoSDKDelegate>)self];
}

- (void)viewDidUnload
{
    _table4FastScroll.dataSource = nil;
    _table4FastScroll.delegate = nil;
    _videoViewTable.dataSource = nil;
    _videoViewTable.delegate = nil;

	_videoDetailInfoController = nil;
	_tudouPersonalInfo = nil;
	_table4FastScroll = nil;
	_videoViewTable = nil;
    _videoInfosArray = nil;
    _videoViewDic = nil;
	[self setVideoViewTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationItem.hidesBackButton = YES;
	self.navigationItem.title = _sinaPersnalInfo.userName;
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
	//self.navigationItem.title = _tudouPersonalInfo.userNickName;
}

- (void) OnReceiveVideoInfo:(TudouVideoInfo*) videoInfo
{
	if (nil != [_videoViewDic objectForKey:videoInfo.itemCode])
	{
		return;
	}
	[_videoInfosArray addObject:videoInfo];

	[_table4FastScroll reloadData];
	[_videoViewTable reloadData];
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


- (void)HideFastVideoTableView
{
	[UIView beginAnimations:nil context:nil];
	CGRect frame = _table4FastScroll.frame;
	frame.origin.x = 321.0f;
	_table4FastScroll.frame = frame;
	_table4FastScroll.alpha = 0.0f;
	[UIView commitAnimations];	
}

- (void)ShowFastVideoTableView
{
	[UIView beginAnimations:nil context:nil];
	CGRect frame = _table4FastScroll.frame;
	frame.origin.x = 279.0f;
	_table4FastScroll.frame = frame;
	_table4FastScroll.alpha = 0.7f;
	[UIView commitAnimations];	
}

#pragma mark - sina weibo sdk delegat
- (void) OnReceiveUserAllWeiBo:(NSArray*) weiBoArray
{
	for (SinaWeiBoData* w in weiBoArray) 
	{
		[_sinaWeiBoSDK requireWeiBoComment:w Delegate:(id<SinaWeiBoSDKDelegate>)self];
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

- (void) OnRecevieWeiBoUserPersonalInfo:(SinaWeiBoUserPersonalInfo*) userInfo
{
	self.navigationItem.title = userInfo.userName;
	_sinaPersnalInfo = userInfo;
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
	[SendWeiBoView sharedSendWeiBoView].weiboDelegate = (id<SinaWeiBoSDKDelegate>)self;
	[SendWeiBoView sharedSendWeiBoView].operationType = SINA_WEIBO_SEND_WEIBO;
	[SendWeiBoView sharedSendWeiBoView].operationData = nil;
	[[SendWeiBoView sharedSendWeiBoView] Show:YES];	
}
#pragma makr - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self ShowFastVideoTableView];
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[self performSelector:@selector(HideFastVideoTableView) withObject:nil afterDelay:3.0f];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.7f];
	self.navigationController.navigationBarHidden = targetContentOffset->y < scrollView.contentOffset.y ? NO : YES;
	
	[UIView commitAnimations];
	return;
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@""];
	TudouVideoInfo* video = ((TudouVideoInfo*)[_videoInfosArray objectAtIndex:indexPath.row]);
    if(tableView == _videoViewTable)
    {
		UIVideoView* v = (UIVideoView*)cell;
        if(nil == v)
        {
            v = [[UIVideoView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, videoViewWidth, videoViewHeigth)];
        }
		v.videoInfo = video;
		v.weiBoData = [[VideoWeiBoDataManager sharedVideoWeiBoDataManager] getWeiBoDataByVideoID:video.itemId];
		[v UpdateView];
		cell = v;
    }
    else
    {
        if(nil == cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
        }
        cell.imageView.image = nil != video.bigPic ? video.bigPic : video.pic;
    }



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
	if (_videoViewTable == tableView) 
	{
		[self performSelector:@selector(HideFastVideoTableView) withObject:nil afterDelay:5.0];
	}
	else 
	{
		[NSObject cancelPreviousPerformRequestsWithTarget:self];
	}
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView == _videoViewTable)
	{
		UIVideoView* cell = (UIVideoView*)[tableView cellForRowAtIndexPath:indexPath];
		if(nil != cell)
		{
			[self OnVideoImageClick:(UIVideoView*)cell];
		}
	}
	else 
	{
		[_videoViewTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];	
	}
	return;
}

@end

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
@property (weak, nonatomic) IBOutlet UIView *backGround;

@property (weak, nonatomic) IBOutlet UIButton *sendNewVideoButton;
@property (strong, nonatomic) TuDouUserPersonalInfo* tudouPersonalInfo;
@property (strong, nonatomic) SinaWeiBoUserPersonalInfo* sinaPersnalInfo;
@property (weak, nonatomic) IBOutlet UITableView *table4FastScroll;
@property (assign, nonatomic) BOOL isSideBarShowing;
@end

@implementation VmeDemoViewController
@synthesize tudouSDK = _tudouSDK;
@synthesize videoViewDic = _videoViewDic;
@synthesize videoInfosArray = _videoInfosArray;
@synthesize tudouUserName = _tudouUserName;
@synthesize videoDetailInfoController = _videoDetailInfoController;
@synthesize videoViewTable = _videoViewTable;
@synthesize backGround = _backGround;
@synthesize sendNewVideoButton = _sendNewVideoButton;
@synthesize tudouPersonalInfo = _tudouPersonalInfo;
@synthesize table4FastScroll = _table4FastScroll;
@synthesize isSideBarShowing = _isSideBarShowing;
@synthesize sinaWeiBoSDK = _sinaWeiBoSDK;
@synthesize sinaPersnalInfo = _sinaPersnalInfo;

#pragma mark - ui operation


const static float videoViewWidth = 320.f;
const static float videoViewHeigth = 292.5 + 25;

- (void) initRelatedData
{
	_videoViewDic = [[NSMutableDictionary alloc] init];
	_videoInfosArray = [[NSMutableArray alloc] init];
	self->currentVideoIndex = 0;
	self->currentPageNo = 1;
	self->totalPageCount = 0;
	self->totalVideoCount = 0;
	_videoDetailInfoController = [[VideoDetailViewController alloc] initWithNibName:nil bundle:nil];
	[_tudouSDK requireUserPersonalInfo:self];
    [_sinaWeiBoSDK requireUserPersonalInfo:(id<SinaWeiBoSDKDelegate>)self];
	[_sinaWeiBoSDK requireUserAllWeiBo:YES UserInfo:NO Delegate:(id<SinaWeiBoSDKDelegate>)self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

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
	_table4FastScroll.alpha = 1.0f;
	
	_backGround.backgroundColor = [UIColor colorWithRed:(237.0 / 256.0) green:(233.0 / 256.0) blue:(227.0 / 256.0) alpha:1.0f];
	[self ShowNewVideoButton];
	_isSideBarShowing = YES;
}

- (void)viewDidUnload
{
    _table4FastScroll.dataSource = nil;
    _table4FastScroll.delegate = nil;
    _videoViewTable.dataSource = nil;
    _videoViewTable.delegate = nil;

	_table4FastScroll = nil;
	_backGround = nil;
	_sendNewVideoButton = nil;
	_isSideBarShowing = NO;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = TRUE;
    self.navigationController.navigationBarHidden = FALSE;
	self.navigationItem.title = _sinaPersnalInfo.userName;
    [_table4FastScroll reloadData];
    [_videoViewTable reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}

- (void) requestMoreVideoInfo
{
    if(self->totalPageCount > self->currentPageNo)
    {
        [_tudouSDK requireUserVideoInfo:self PageNo:(self->currentPageNo + 1)];
    }
}

#pragma mark - tudousdk delegate
- (void) OnReceiveUserPersonalInfo:(TuDouUserPersonalInfo*) userPersonalInfo
{
    self->totalPageCount = 1;
	self->currentPageNo = 0;
    [self requestMoreVideoInfo];
    _tudouPersonalInfo = userPersonalInfo;
}

- (void) OnReceiveVideoInfo:(TudouVideoInfo*) videoInfo
{
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

- (void) HideNewVideoButton
{
	_isSideBarShowing = NO;
	[UIView beginAnimations:nil context:nil];
	CGRect frame = _sendNewVideoButton.frame;
	frame.origin.x = 321.0f;
	_sendNewVideoButton.frame = frame;
	_sendNewVideoButton.alpha = 0.0f;
	[UIView commitAnimations];
	[self performSelector:@selector(HideFastVideoTableView) withObject:nil afterDelay:0.2f];
	
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

- (void)ShowNewVideoButton
{
	_isSideBarShowing = YES;
	[UIView beginAnimations:nil context:nil];
	CGRect frame = _sendNewVideoButton.frame;
	frame.origin.x = 265.0f;
	_sendNewVideoButton.frame = frame;
	_sendNewVideoButton.alpha = 0.7f;
	frame = _table4FastScroll.frame;
	frame.origin.x = 265.0f;
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
		UIVideoView* v = [_videoViewDic objectForKey:[w.annotation objectAtIndex:0]];
		if (nil != v)
		{
			v.weiBoData = w;
			[v UpdateView];
		}

	}
//    [_sinaWeiBoSDK requireBatchWeiBoComment:weiBoArray Delegate:(id<SinaWeiBoSDKDelegate>)self];
	
}

- (void) OnReceiveSendWeiBoResult:(SinaWeiBoData*) sendResult
{
	UIVideoView* v = [_videoViewDic objectForKey:[sendResult.annotation objectAtIndex:0]];
	if(nil != v)
	{
		v.weiBoData = sendResult;
		[v UpdateView];
	}
	
}

- (void) OnReceiveCommentForWeiBo:(SinaWeiBoData*) weiBo Comments:(NSArray*)comments
{
	UIVideoView* v = [_videoViewDic objectForKey:[weiBo.annotation objectAtIndex:0]];
	if (nil != v)
	{
		[v UpdateView];
	}
	
}

- (void) OnRecevieWeiBoUserPersonalInfo:(SinaWeiBoUserPersonalInfo*) userInfo
{
	self.navigationItem.title = userInfo.userName;
	_sinaPersnalInfo = userInfo;
}

#pragma mark - UIVideoView delegate
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

	[self ShowNewVideoButton];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if(_isSideBarShowing)
	{
		[self performSelector:@selector(HideNewVideoButton) withObject:nil afterDelay:3.0f];
	}
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
            
            v = [[UIVideoView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, videoViewWidth, videoViewHeigth)];
        }
		v.videoInfo = video;
		v.weiBoData = [[VideoWeiBoDataManager sharedVideoWeiBoDataManager] getWeiBoDataByVideoID:video.itemCode];
		[v UpdateView];
        v.videoViewDelegate = (id<UIVideoViewDelegate>)self;
		cell = v;
        for (NSString* key in [_videoViewDic allKeys])
        {
            UIVideoView* o = [_videoViewDic objectForKey:key];
            if(video.itemCode == o.videoInfo.itemCode || [o.videoInfo.itemCode isEqualToString:video.itemCode])
            {
                [_videoViewDic removeObjectForKey:key];
                break;
            }
        }
        [_videoViewDic setObject:v forKey:video.itemCode];
        if(indexPath.row == [_videoInfosArray count] - 1)
        {
            //请求更过视屏数据
            [self requestMoreVideoInfo];
        }
    }
    else
    {
        if(nil == cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
        }
        cell.imageView.image = nil != video.bigPic ? video.bigPic : video.pic;
    }


    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
		[self performSelector:@selector(HideNewVideoButton) withObject:nil afterDelay:2.5f];
	}
	
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView == _videoViewTable)
	{
		UIVideoView* cell = (UIVideoView*)[tableView cellForRowAtIndexPath:indexPath];
		if(nil != cell)
		{
            self.navigationItem.title = nil;
            _videoDetailInfoController.videoInfo = cell.videoInfo;
            _videoDetailInfoController.sinaWeiBoSDK = _sinaWeiBoSDK;
            [[self navigationController] pushViewController:_videoDetailInfoController animated:YES];
		}
	}
	else 
	{
		[_videoViewTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];	
	}
	return;
}

@end

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
@interface VmeDemoViewController ()

@property (strong, nonatomic) NSMutableArray* imageViewArray;
@property (strong, nonatomic) NSMutableArray* videoInfosArray;
@property (strong, nonatomic) VideoDetailViewController* videoDetailInfoController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewForImage;
@property (strong, nonatomic) TuDouUserPersonalInfo* tudouPersonalInfo;
@end

@implementation VmeDemoViewController
@synthesize tudouSDK = _tudouSDK;
@synthesize imageViewArray = _imageViewArray;
@synthesize videoInfosArray = _videoInfosArray;
@synthesize tudouUserName = _tudouUserName;
@synthesize videoDetailInfoController = _videoDetailInfoController;
@synthesize indicator = _indicator;
@synthesize scrollViewForImage = _scrollViewForImage;
@synthesize tudouPersonalInfo = _tudouPersonalInfo;
@synthesize sinaWeiBoSDK = _sinaWeiBoSDK;

static const int imageCountForRow = 3;
static const float imageWidth = 100.0f;
static const float xPosition[imageCountForRow] = {5.0f, 110.0f, 215.0f};
static const float imageDis = 5.0f;
static float yPosition[imageCountForRow] = {imageDis, imageDis, imageDis};
			  
#pragma mark - ui operation

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Do any additional setup after loading the view, typically from a nib.
	_imageViewArray = [[NSMutableArray alloc] init];
	_videoInfosArray = [[NSMutableArray alloc] init];
	self->currentVideoIndex = 0;
	self->currentPageNo = 1;
	self->totalPageCount = 0;
	self->totalVideoCount = 0;

	[[self view] setBackgroundColor:[UIColor whiteColor]];
	_videoDetailInfoController = [[VideoDetailViewController alloc] initWithNibName:nil bundle:nil];
	_scrollViewForImage.showsVerticalScrollIndicator = NO;
	_scrollViewForImage.delegate = self;
	[_indicator startAnimating];
	[_sinaWeiBoSDK requireUserAllWeiBo:YES Delegate:self];
}

- (void)viewDidUnload
{
	_videoInfosArray = nil;
	_imageViewArray = nil;
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
	int index = [_videoInfosArray count] % imageCountForRow;
	index = 0 == index ? imageCountForRow - 1 : index - 1; 
	CGSize imageSize = videoInfo.pic.size;
	float imageShowHeight = imageSize.height * imageWidth / imageSize.width;
	
	UIImageTouchableView* imageView = [[UIImageTouchableView alloc] initWithFrame:CGRectMake(xPosition[index], yPosition[index], imageWidth, imageShowHeight)];
	yPosition[index] += (imageShowHeight + imageDis);
	[_scrollViewForImage addSubview:imageView];
	[imageView addTarget:self action:@selector(onUIImageClicked:) forControlEvents:UIControlEventTouchDown];
	imageView.image = videoInfo.pic;
	imageView.userData = videoInfo;
	
	CGSize size = CGSizeMake(320, MAX(_scrollViewForImage.contentSize.height, MAX(MAX(yPosition[0], yPosition[1]), yPosition[2])));
	_scrollViewForImage.contentSize = size;
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

#pragma mark - ui event handler
- (void) onUIImageClicked:(id)sender
{
	UIImageTouchableView* imageView = (UIImageTouchableView*)sender;
	TudouVideoInfo* video = (TudouVideoInfo*)[imageView userData];
	if (nil == video) 
	{
		return;
	}
	self.navigationItem.title = nil;
	_videoDetailInfoController.videoInfo = video;
	_videoDetailInfoController.sinaWeiBoSDK = _sinaWeiBoSDK;
	[[self navigationController] pushViewController:_videoDetailInfoController animated:YES];
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

@end

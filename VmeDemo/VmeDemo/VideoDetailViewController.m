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
#import "Utility.h"
#import <QuartzCore/QuartzCore.h>

@interface VideoDetailViewController ()

@property (weak, nonatomic)
IBOutlet UIImageTouchableView *bigPicImageView;
@property (weak, nonatomic) IBOutlet UITableView *commentTableView;
@property (weak, nonatomic) IBOutlet UIImageView *bigPicBack;
@property (strong, nonatomic) VideoPageViewController* webView;
@property (weak, nonatomic) SinaWeiBoData* weiBoData;
@property (strong, nonatomic) CommentView* viewForCaculate;
@end


@implementation VideoDetailViewController
@synthesize bigPicImageView = _bigPicImageView;
@synthesize commentTableView = _commentTableView;
@synthesize bigPicBack = _bigPicBack;
@synthesize webView = _webView;
@synthesize weiBoData = _weiBoData;
@synthesize viewForCaculate = _viewForCaculate;

@synthesize sinaWeiBoSDK = _sinaWeiBoSDK;
@synthesize videoInfo = _videoInfo;



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
	self.view.backgroundColor = [UIColor colorWithRed:(237.0 / 256.0) green:(233.0 / 256.0) blue:(227.0 / 256.0) alpha:1.0f];
	//添加视频截图
	[_bigPicImageView addTarget:self action:@selector(onBigImageClicked:) forControlEvents:UIControlEventTouchDown];
    _bigPicImageView.backgroundColor = [UIColor clearColor];
	
	_webView = [[VideoPageViewController alloc] init];
    _commentTableView.backgroundColor = [UIColor clearColor];
    _commentTableView.separatorStyle = NO;
    _commentTableView.dataSource = (id<UITableViewDataSource>)self;
    _commentTableView.delegate = (id<UITableViewDelegate>)self;
    
    _viewForCaculate = [[CommentView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300, 50)];

}

- (void)viewDidUnload
{
	_bigPicImageView = nil;
	_videoInfo = nil;
    _commentTableView = nil;
    _viewForCaculate = nil;
	[self setBigPicBack:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[_bigPicImageView setImage:nil];
	self.navigationItem.title = _videoInfo.title;
	[[ImageManager sharedImageManager] postURL2DownLoadImage:_videoInfo.bigPicURL Delegate:self];
	self.navigationController.navigationBarHidden = NO;
	//查找该视频是否已经发送过weibo,如果发送过,尝试得到该微博的评论
	_weiBoData = [[VideoWeiBoDataManager sharedVideoWeiBoDataManager] getWeiBoDataByVideoID:_videoInfo.itemCode];
    if (nil != _weiBoData)
    {
        if(nil == _weiBoData.comments)
        {
            [_sinaWeiBoSDK requireWeiBoComment:_weiBoData Delegate:(id<SinaWeiBoSDKDelegate>)self];
        }
    }
    else
    {
        //如果没有发送，则显示发送微博按钮
        
    }
    [_commentTableView reloadData];
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(nil == _weiBoData)
    {
        return 50.0f;
    }
    
    if (0 != indexPath.row)
    {
        SinaWeiBoComment* comment = [_weiBoData.comments objectAtIndex:indexPath.row - 1];
        _viewForCaculate.userData = (id)comment;
        [_viewForCaculate settext:comment.text];
        [_viewForCaculate setAvatarImage:comment.userInfo.avatarImage];
        [_viewForCaculate setPopDirection:YES];
    }
    else
    {
        _viewForCaculate.userData = (id)_weiBoData;
        [_viewForCaculate settext:_weiBoData.text];
        [_viewForCaculate setAvatarImage:_weiBoData.userInfo.avatarImage];
        [_viewForCaculate setPopDirection:YES];
    }
    return _viewForCaculate.frame.size.height + 10.0f;
}

#pragma mark - UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if(nil == _weiBoData)
    {
        //只能发送微博
        return [self sendSinaWeiBo];
    }
    
    [self sendComment:indexPath.row];
	return;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:nil != _weiBoData ? @"" : @"sina"];
    if (nil == _weiBoData)
    {
        if(nil == cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sina"];
        }
        cell.imageView.image = [[ImageManager sharedImageManager] getImageFromBundle:@"share2Sina.gif"];
        cell.frame = CGRectMake(0.0f, 0.0f, 300.f, 50.0f);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    CommentView* result = (CommentView*)cell;
    if(nil == result)
    {
        result = [[CommentView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.f, 50.0f)];
    }
    if(0 != indexPath.row)
    {
        int row = indexPath.row - 1;
        SinaWeiBoComment* comment = [_weiBoData.comments objectAtIndex:row];
        result.userData = (id)comment;
        [result settext:comment.text];
        [result setAvatarImage:comment.userInfo.avatarImage];
        [result setPopDirection:YES];
        result.type = @"Comment";
    }
    else
    {
        result.userData = (id)_weiBoData;
        [result settext:_weiBoData.text];
        [result setAvatarImage:_weiBoData.userInfo.avatarImage];
        [result setPopDirection:YES];
        result.type = @"WeiBo";
    }
    result.selectionStyle = UITableViewCellSelectionStyleNone;
    //result.delegate = (id<CommentViewDelegate>)self;
    return result;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return nil != _weiBoData ? (nil != _weiBoData.comments ? [_weiBoData.comments count] + 1 : 1) : 1;
}

#pragma mark - url image request delegate
- (void) OnReceiveImage:(UIImage*)image ImageUrl:(NSString *)imageUrl
{
	if ([_videoInfo.bigPicURL isEqualToString:imageUrl]) 
	{
		_videoInfo.bigPic = image;
		_bigPicImageView.image = _videoInfo.bigPic;
	}

}

#pragma mark - big image clicked
- (void) onBigImageClicked:(id)sender
{
	_webView.videoInfo = _videoInfo;
	[self navigationItem].title = nil;
	[[self navigationController] pushViewController:_webView animated:YES];
}

- (void) sendSinaWeiBo
{
	[SendWeiBoView sharedSendWeiBoView].videoInfo = _videoInfo;
	[SendWeiBoView sharedSendWeiBoView].weiBoSDK = _sinaWeiBoSDK;
	[SendWeiBoView sharedSendWeiBoView].weiboDelegate = (id<SinaWeiBoSDKDelegate>)self;
	[SendWeiBoView sharedSendWeiBoView].operationType = SINA_WEIBO_SEND_WEIBO;
	[SendWeiBoView sharedSendWeiBoView].operationData = nil;
	[[SendWeiBoView sharedSendWeiBoView] Show:YES];
	return;
}

#pragma mark - sina weibo sdk delegate
- (void) OnReceiveSendWeiBoResult:(SinaWeiBoData*) sendResult
{

	NSString* itemCode = [sendResult.annotation objectAtIndex:0];
	if(nil != _videoInfo && [itemCode isEqualToString:_videoInfo.itemCode])
	{
        [_commentTableView reloadData];
    }
}

- (void) OnReceiveCommentForWeiBo:(SinaWeiBoData*) weiBo Comments:(NSArray*)comments
{
	NSString* itemCode = [weiBo.annotation objectAtIndex:0];
	if(nil != _videoInfo && [itemCode isEqualToString:_videoInfo.itemCode])
	{
        [_commentTableView reloadData];
    }
}

- (void) OnReceiveCommentReplyResult:(SinaWeiBoComment*)result
{
	NSString* itemCode = [result.weiBoData.annotation objectAtIndex:0];
	if(nil != _videoInfo && [itemCode isEqualToString:_videoInfo.itemCode])
	{
        [_commentTableView reloadData];
    }
}

#pragma mark - CommentView delegate
- (void) sendComment:(int)index
{
	[SendWeiBoView sharedSendWeiBoView].videoInfo = _videoInfo;
	[SendWeiBoView sharedSendWeiBoView].weiBoSDK = _sinaWeiBoSDK;
	[SendWeiBoView sharedSendWeiBoView].weiboDelegate = (id<SinaWeiBoSDKDelegate>)self;
	[SendWeiBoView sharedSendWeiBoView].operationData = 0 == index ? _weiBoData : [_weiBoData.comments objectAtIndex:index - 1];
	[SendWeiBoView sharedSendWeiBoView].operationType = 0 == index ? SINA_WEIBO_CREATE_COMMENT : SINA_WEIBO_REPLY_COMMENT;
	[[SendWeiBoView sharedSendWeiBoView] Show:YES];
}

@end

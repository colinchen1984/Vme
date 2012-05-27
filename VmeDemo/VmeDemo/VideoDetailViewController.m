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
@interface VideoDetailViewController ()
@property (strong, nonatomic) IBOutlet UIImageTouchableView *bigPicImageView;
@property (weak, nonatomic) IBOutlet UIButton *share2SinaWeibo;
@property (weak, nonatomic) IBOutlet UIButton *share2TencentWeiBo;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bigPicIndicator;
@property (strong, nonatomic) NSString* userNickName;
@property (strong, nonatomic) VideoPageViewController* webView;
@end

@implementation VideoDetailViewController
@synthesize bigPicImageView = _bigPicImageView;
@synthesize share2SinaWeibo = _share2SinaWeibo;
@synthesize share2TencentWeiBo = _share2TencentWeiBo;
@synthesize scrollView = _scrollView;
@synthesize bigPicIndicator = _bigPicIndicator;
@synthesize videoInfo = _videoInfo;
@synthesize userNickName = _userNickName;
@synthesize webView = _webView;
@synthesize sinaWeiBoSDK = _sinaWeiBoSDK;

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
}

- (void)viewDidUnload
{
	[self setBigPicIndicator:nil];
	[self setVideoInfo:nil];
	[self setBigPicImageView:nil];
	[self setShare2SinaWeibo:nil];
	[self setShare2TencentWeiBo:nil];
	[self setUserNickName:nil];
	[self setScrollView:nil];
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
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - url image request delegate
- (void) OnReceiveImage:(UIImage*)image
{
	_videoInfo.bigPic = image;
	[_bigPicIndicator stopAnimating];
	[_bigPicImageView setImage:_videoInfo.bigPic];
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
	NSString* text = [[NSString alloc] initWithFormat:@"colin chenTest测试\r\n%@", _videoInfo.itemUrl];
	NSString* annotation = [[NSString alloc] initWithFormat:@"[\"%@\"]", _videoInfo.itemId];
	[_sinaWeiBoSDK sendWeiBo:text Annotations:annotation Delegate:nil];
}

#pragma mark - sina weibo sdk delegate

- (void) OnReceiveSendWeiBoResult:(SinaWeiBOSendWeiBoResult*) sendResult
{

}
@end

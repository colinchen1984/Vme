//
//  VideoPageViewController.m
//  VmeDemo
//
//  Created by user on 12-5-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VideoPageViewController.h"
#import "TuDouSDK.h"
@interface VideoPageViewController ()
@property (nonatomic) BOOL needReloadWeb;
@property (strong, nonatomic) UIWebView* webView;
@end

@implementation VideoPageViewController

@synthesize webView = _webView;
@synthesize videoInfo = _videoInfo;
@synthesize needReloadWeb = _needReloadWeb;

- (void) setVideoInfo:(TudouVideoInfo*)videoInfo
{
	if(_videoInfo == videoInfo)
	{
		return;
	}
	_videoInfo = videoInfo;
	_needReloadWeb = YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
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
	// Do any additional setup after loading the view.
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480 )];
	[_webView setScalesPageToFit:YES];
	[[self view] addSubview:_webView];
	_needReloadWeb = YES;
}

- (void)viewDidUnload
{
	_webView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationItem.leftBarButtonItem.style = UIBarButtonSystemItemCancel;
	self.navigationItem.title = _videoInfo.title;
	if(YES == _needReloadWeb)
	{
		_needReloadWeb = NO;
		NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:_videoInfo.itemUrl]
												cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
											timeoutInterval:60.0];
		[_webView loadRequest:request];	
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[_webView stopLoading];
	[super viewWillDisappear:animated];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end

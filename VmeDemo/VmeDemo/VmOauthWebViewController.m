//
//  VmOauthWebViewController.m
//  VmeDemo
//
//  Created by user on 12-5-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VmOauthWebViewController.h"
#import "Oauth.h"

@interface VmOauthWebViewController ()
@property (strong, nonatomic) UIWebView* webView;
@property (weak, nonatomic) OauthEngine* engine;
@end

@implementation VmOauthWebViewController
@synthesize webView = _webView;
@synthesize engine = _engine;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
	[_webView setDelegate:self];
	[[self view] addSubview:_webView];
}

- (void)viewDidUnload
{
	if (_webView.delegate == self) {
		_webView.delegate = nil;
	}
	_webView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) loadUrl:(NSString*) url OauthEngine:(OauthEngine*) engine
{
	NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];
    [_webView loadRequest:request];
	[_webView setAlpha:0];
	CGAffineTransform transform = CGAffineTransformIdentity;
	[_webView setTransform:CGAffineTransformScale(transform, 0.10f, 0.10f)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3f];
	[_webView setAlpha:1.0f];
	[_webView setTransform:CGAffineTransformScale(transform,1.0f, 1.0f)];
	[UIView commitAnimations];
	_engine = engine;
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSString* str = request.URL.absoluteString;
	[_engine handleOauthWebViewData:str];
    
    return YES;
}
@end

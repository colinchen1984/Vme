//
//  VmeStartUp.m
//  VmeDemo
//
//  Created by user on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VmeStartUp.h"
#import "Oauth.h"
#import "SinaWeiBoOauth.h"
@interface VmeStartUpController()
@end

@implementation VmeStartUpController
@synthesize startUpView = _startUpView;
@synthesize tudouOuath = _tudouOauth;
@synthesize sinaOauth = _sinaOauth;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"VmeStartUpView" bundle:nil];
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
}

- (void)viewDidUnload
{
	[self setStartUpView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)loginTudou:(id)sender 
{
	NSString* str = [_sinaOauth class];

	[_sinaOauth oauthStart];
}
@end

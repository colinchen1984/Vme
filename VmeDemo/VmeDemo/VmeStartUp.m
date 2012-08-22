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
#import "SFHFKeychainUtils.h"
#import "VmeDemoViewController.h"
#import "ImageManager.h"
#import "GTMBase64.h"

@interface VmeStartUpController()
@property (strong, nonatomic) OauthEngine* tudouOuath;
@property (strong, nonatomic) SinaWeiBoOauth* sinaOauth;
@property (strong, nonatomic) NSString* tudouUserName;
@property (strong, nonatomic) NSString* tudouUserPass;
@property (weak, nonatomic) IBOutlet UITextField *inputTudouUserName;
@property (weak, nonatomic) IBOutlet UITextField *inputTudoUserPassword;
@property (weak, nonatomic) IBOutlet UIButton *loginSina;
@property (strong, nonatomic) VmeDemoViewController *videoController;
@property (strong, nonatomic) TuDouSDK* tudouSDK;
@property (strong, nonatomic) SinaWeiBoSDK* sinaWeiboSDK;
@property (strong, nonatomic) UIImageView* loadingImage;

@end

@implementation VmeStartUpController
@synthesize startUpView = _startUpView;
@synthesize sinaOauth = _sinaOauth;
@synthesize tudouUserName = _tudouUserName;
@synthesize tudouUserPass = _tudouUserPass;
@synthesize inputTudouUserName = _inputTudouUserName;
@synthesize inputTudoUserPassword = _inputTudoUserPassword;
@synthesize loginSina = _loginSina;
@synthesize loadingImage = _loadingImage;
@synthesize videoController = _videoController;
@synthesize tudouSDK = _tudouSDK;
@synthesize sinaWeiboSDK = _sinaWeiboSDK;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"VmeStartUpView" bundle:nil];
    if (nil == self) 
	{
        // Custom initialization
		return nil;
    }
	
	_sinaOauth = [[SinaWeiBoOauth alloc] init];
	_sinaWeiboSDK = [[SinaWeiBoSDK alloc] initWithSinaWeiBoOauth:_sinaOauth];
	_sinaOauth.delegate = (id<OauthDelegate>)self;
	_videoController = [[VmeDemoViewController alloc] initWithNibName:nil bundle:nil];
    CGRect frame = self.view.frame;
    frame.origin.y += 0.0f;
    _loadingImage = [[UIImageView alloc] initWithFrame:frame];
    [self.view addSubview:_loadingImage];
    _loadingImage.image = [[ImageManager sharedImageManager] getImageFromBundle:@"load.png"];
	_inputTudouUserName.delegate = (id<UITextFieldDelegate>)self;
	_inputTudoUserPassword.delegate = (id<UITextFieldDelegate>)self;
	_inputTudoUserPassword.hidden = YES;
	_inputTudouUserName.hidden = YES;
    //_tudouUserName = @"_79592344";
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
	_startUpView = nil;
	_loginSina = nil;
	_inputTudouUserName.delegate = nil;
	_inputTudouUserName = nil;
    _loadingImage = nil;
	_inputTudoUserPassword.delegate = nil;
	_inputTudoUserPassword = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = YES;
    [self performSelector:@selector(removeloading) withObject:nil afterDelay:3.5f];
	[_sinaOauth loadAccessToken];

	[self loadTuDouUserName];
	
	if (NO != [_sinaOauth expires])
	{
		[self startLoginSina];
		return;
	}
	
	
	//檢查token是否有效
	[_sinaWeiboSDK requireUserPersonalInfo:(id<SinaWeiBoSDKDelegate>)self];
}

- (void) removestop
{
	[_loadingImage removeFromSuperview];
	_loadingImage.image = nil;
	_loadingImage = nil;
}

- (void) removeloading
{
    [UIView beginAnimations:nil context:nil];
    [UIImageView setAnimationDuration:2.0f];
	//[UIView setAnimationDidStopSelector:@selector(removestop)];
    _loadingImage.alpha = 0.0f;
    [UIView commitAnimations];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (NO == [_sinaOauth expires] && nil != _tudouUserName) 
	{
		[self finishLogin];
		return;
	}
	
}

- (void) startLoginSina
{
	_inputTudouUserName.hidden = YES;
	_inputTudoUserPassword.hidden = YES;
	_loginSina.hidden = NO;
}

- (void) startloginTudou
{
	_loginSina.hidden = YES;
	_inputTudouUserName.hidden = NO;
	_inputTudoUserPassword.hidden = NO;
}

- (void) finishLogin
{
	_videoController.tudouUserName = _tudouUserName;
	_tudouSDK = [[TuDouSDK alloc] initUserName:_tudouUserName Pass:_tudouUserPass];
	_videoController.tudouSDK = _tudouSDK;
	_videoController.sinaWeiBoSDK = _sinaWeiboSDK;
	self.navigationItem.title = nil;
	[self.navigationController pushViewController:_videoController animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) loadTuDouUserName
{
	return;
	_tudouUserName = [SFHFKeychainUtils getPasswordForUsername:@"TuDouUserName" andServiceName:@"TuDou" error:nil];	
}

- (void) saveTuDouUserName
{
	[SFHFKeychainUtils storeUsername:@"TuDouUserName" andPassword:_tudouUserName forServiceName:@"TuDou" updateExisting:YES error:nil];
}

- (IBAction)loginSina:(id)sender
{
	[_sinaOauth oauthStart];
}

- (void) OnOauthLoginSucessce
{
	if (_tudouUserName) 
	{
		[self finishLogin];
	}
	else
	{
		[self startloginTudou];
	}

}

- (void) OnOauthLoginFail
{

}

- (void) OnAlreadyLogin
{
	if (_tudouUserName) 
	{
		[self finishLogin];
	}
	else
	{
		[self startloginTudou];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == _inputTudouUserName)
	{
		_tudouUserName = @"_79592344";
		if(nil == _tudouUserPass)
		{
			[_inputTudoUserPassword becomeFirstResponder];
		}
		else
		{
			[self finishLogin];
		}

	}
	else if(textField == _inputTudoUserPassword)
	{
		_tudouUserName = @"_79592344";
		_tudouUserPass = textField.text;
		if (nil == _tudouUserName)
		{
			[_inputTudouUserName becomeFirstResponder];
		}
		else
		{
			[self finishLogin];
		}
		
	}
	
	return NO;
}

#pragma make - sina sdk delegate
- (void) OnRecevieWeiBoUserPersonalInfo:(SinaWeiBoUserPersonalInfo*) userInfo
{
	//[self removeloading];
	if(nil == _tudouUserName)
	{
		[self startloginTudou];
	}
	else
	{
		[self finishLogin];
	}
	
}

- (void) OnError:(NSString*)data
{
	NSLog(@"%@", data);
	//[self removeloading];
	[self startLoginSina];
	return;
	[_sinaOauth cleanAccessToken];
	[self startLoginSina];

}
@end

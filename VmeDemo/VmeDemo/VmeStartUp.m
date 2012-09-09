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
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

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
@synthesize indicator = _indicator;
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
	
	[self loadTuDouUserData];
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
	_sinaOauth = [[SinaWeiBoOauth alloc] init];
	_sinaWeiboSDK = [[SinaWeiBoSDK alloc] initWithSinaWeiBoOauth:_sinaOauth];
	_tudouSDK = [[TuDouSDK alloc] initUserName:nil Pass:nil];
	_sinaOauth.delegate = (id<OauthDelegate>)self;
	_videoController = [[VmeDemoViewController alloc] initWithNibName:nil bundle:nil];
	_indicator = [ [ UIActivityIndicatorView  alloc ]
				  initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];

	_indicator.center = _inputTudouUserName.center;
	_indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
   	[self.view addSubview:_indicator];
	CGRect frame = self.view.frame;
    frame.origin.y += 0.0f;
    _loadingImage = [[UIImageView alloc] initWithFrame:frame];
    [self.view addSubview:_loadingImage];
    _loadingImage.image = [[ImageManager sharedImageManager] getImageFromBundle:@"load.png"];
	_inputTudouUserName.delegate = (id<UITextFieldDelegate>)self;
	_inputTudoUserPassword.delegate = (id<UITextFieldDelegate>)self;
	_inputTudoUserPassword.hidden = YES;
	_inputTudouUserName.hidden = YES;
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
	_sinaOauth = nil;
	_sinaWeiboSDK = nil;
	_tudouUserName = nil;
	_tudouUserPass = nil;
	_tudouSDK = nil;
	[_indicator removeFromSuperview];
	_indicator = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = YES;
    [self performSelector:@selector(removeloading) withObject:nil afterDelay:5.5f];
	_indicator.hidden = YES;
	_indicator.hidesWhenStopped = YES;
	CGPoint center = _indicator.center;
	CGRect frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
	_indicator.frame = frame;
	_indicator.center = center;
	[_sinaOauth loadAccessToken];
	
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

/*- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (NO == [_sinaOauth expires] && nil != _tudouUserName) 
	{
		[self finishLogin];
		return;
	}
	
}*/

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

- (void) CheckTudouUserData
{
	//利用土豆的向土豆發起上傳視頻的請求來驗證用戶名和帳號的有效性
	//

	[_tudouSDK checkUserName:_tudouUserName Pass:_tudouUserPass Delegate:(id<TuDouSDKDelegate>)self];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) loadTuDouUserData
{
	_tudouUserName = [SFHFKeychainUtils getPasswordForUsername:@"TuDouUserName" andServiceName:@"TuDou" error:nil];
	_tudouUserPass = [SFHFKeychainUtils getPasswordForUsername:@"TuDouUserPass" andServiceName:@"TuDou" error:nil];
}

- (void) saveTuDouUserData
{
	[SFHFKeychainUtils storeUsername:@"TuDouUserName" andPassword:_tudouUserName forServiceName:@"TuDou" updateExisting:YES error:nil];
	[SFHFKeychainUtils storeUsername:@"TuDouUserPass" andPassword:_tudouUserPass forServiceName:@"TuDou" updateExisting:YES error:nil];
}

- (void) cleanTuDouUserData
{
	[SFHFKeychainUtils deleteItemForUsername:@"TuDouUserName"  andServiceName:@"TuDou" error:nil];
	[SFHFKeychainUtils deleteItemForUsername:@"TuDouUserPass"  andServiceName:@"TuDou" error:nil];
}

- (IBAction)loginSina:(id)sender
{
	[_sinaOauth oauthStart];
}

- (void) OnOauthLoginSucessce
{
	if (_tudouUserName) 
	{
		[self CheckTudouUserData];
	}
	else
	{
		[self startloginTudou];
	}

}

- (void) OnOauthLoginFail
{
	//通知新浪微博登錄錯誤，請重試
	
	[self startLoginSina];
}

- (void) OnAlreadyLogin
{
	if (_tudouUserName) 
	{
		[self CheckTudouUserData];
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
		_tudouUserName = _inputTudouUserName.text;
		if([_tudouUserName isEqualToString:@""])
		{
			return NO;
		}
		_inputTudoUserPassword.text = nil;
		[_inputTudoUserPassword becomeFirstResponder];

	}
	else if(textField == _inputTudoUserPassword)
	{
		_tudouUserPass = _inputTudoUserPassword.text;
		_tudouUserName = _inputTudouUserName.text;
		if([_tudouUserPass isEqualToString:@""])
		{
			return NO;
		}
		else if(nil == _tudouUserName || [_tudouUserName isEqualToString:@""])
		{
			[_inputTudouUserName becomeFirstResponder];
		}
		
		else
		{
			_indicator.hidden = NO;
			[_indicator startAnimating];
			[self CheckTudouUserData];
		}
		
	}
	
	return NO;
}
#pragma mark - tudo sdk delegate
- (void) OnReceiveCheckUserNamePass:(BOOL)result
{
	[_indicator stopAnimating];
	if (result)
	{
		[self saveTuDouUserData];
		_videoController.tudouUserName = _tudouUserName;
		[_tudouSDK setUserName:_tudouUserName Pass:_tudouUserPass];
		_videoController.tudouSDK = _tudouSDK;
		_videoController.sinaWeiBoSDK = _sinaWeiboSDK;
		[_videoController initRelatedData];
		self.navigationItem.title = nil;
		[self.navigationController pushViewController:_videoController animated:YES];
	}
	else
	{
		//提示用戶名密碼錯誤
		
		[self startloginTudou];
	}
}
#pragma mark - sina sdk delegate
- (void) OnRecevieWeiBoUserPersonalInfo:(SinaWeiBoUserPersonalInfo*) userInfo
{
	//[self removeloading];
	
	if(nil == _tudouUserName)
	{
		[self startloginTudou];
	}
	else
	{
		[self CheckTudouUserData];
	}
	
}

- (void) OnError:(NSString*)data
{
	NSLog(@"%@", data);
	[_sinaOauth cleanAccessToken];
	[self startLoginSina];

}
@end

//
//  VmeStartUp.h
//  VmeDemo
//
//  Created by user on 12-5-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OauthEngine;
@class SinaWeiBoOauth;

@interface VmeStartUpController : UIViewController
@property (weak, nonatomic) OauthEngine* tudouOuath;
@property (strong, nonatomic) IBOutlet UIView *startUpView;
@property (weak, nonatomic) SinaWeiBoOauth* sinaOauth;
@end

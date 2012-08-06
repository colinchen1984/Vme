//
//  UIImageTouchableView.h
//  VmeDemo
//
//  Created by user on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageTouchableView : UIButton

@property (weak, nonatomic) id userData;
- (void) setImage:(UIImage*) image;
@end

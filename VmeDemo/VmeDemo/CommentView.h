//
//  CommentView.h
//  VmeDemo
//
//  Created by user on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentView : UIView
- (void) setPopDirection:(BOOL)isLeft;
- (void) setAvatarImage:(UIImage*)avatarImage;
- (void) settext:(NSString*)text;
@property (weak, nonatomic) id userData;
@end

//
//  SendWeiBoView.m
//  VmeDemo
//
//  Created by user on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SendWeiBoView.h"
#import "ImageManager.h"
#import "TuDouSDK.h"
#import "SinaWeiBoSDK.h"
#import <QuartzCore/QuartzCore.h> 
#import <UIKit/UIFont.h>
@interface SendWeiBoView()
@property (strong, nonatomic) UIView* backGroundView;
@property (strong, nonatomic) UILabel* titleLable;
@property (strong, nonatomic) UITextView* textView;
@property (strong, nonatomic) UIButton* sendButton;
@property (strong, nonatomic) UILabel* wordCount;
@end

@implementation SendWeiBoView
@synthesize weiBoSDK = _weiBoSDK;
@synthesize videoInfo = _videoInfo;
@synthesize backGroundView = _backGroundView;
@synthesize titleLable = _titleLable;
@synthesize textView = _textView;
@synthesize sendButton = _sendButton;
@synthesize wordCount = _wordCount;
@synthesize weiboDelegate = _weiboDelegate;
- (id)initWithFrame:(CGRect)frame
{
    self = 
	[super initWithFrame:frame];
    if (nil == self) 
	{
        return nil;
    }
	_backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)];
	_backGroundView.alpha = 0.85f;
	_backGroundView.backgroundColor = [UIColor blackColor];
	self.backgroundColor = [UIColor whiteColor];
	self.frame = CGRectMake(10.0f, 100.0f, 300.0f, 280.0f);
	[self setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.55]];
	[[self layer] setMasksToBounds:NO]; // very important
	[[self layer] setCornerRadius:16.89f];
	
	UIButton* cancelButton = [[UIButton alloc] init];
	cancelButton.frame = CGRectMake(0.0f, 0, 35, 35);
	cancelButton.titleLabel.text = @"Cancel";
	cancelButton.contentMode = UIViewContentModeScaleToFill;
	[cancelButton setImage:[[ImageManager sharedImageManager] getImageFromBundle:@"cancel.png"] forState:UIControlStateNormal];
	[cancelButton addTarget:self action:@selector(cancelSendWeiBo:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:cancelButton];
	
	_titleLable = [[UILabel alloc] init];
	_titleLable.frame = CGRectMake(45.0f, 0.0f, 200.0f, 35);
	_titleLable.textAlignment = UITextAlignmentCenter;
	[self addSubview:_titleLable];
	
	
	_sendButton = [[UIButton alloc] init];
	_sendButton.frame = CGRectMake(250.0f, 0, 35, 35);
	[_sendButton setTitle:NSLocalizedString(@"发送", nil)  forState:UIControlStateNormal];
	_sendButton.contentMode = UIViewContentModeScaleToFill;
	[_sendButton setImage:[[ImageManager sharedImageManager] getImageFromBundle:@"cancel.png"] forState:UIControlStateNormal];
	[_sendButton addTarget:self action:@selector(sendSinaWeiBo:) forControlEvents:UIControlEventTouchDown];
	[self addSubview:_sendButton];
	
	_textView = [[UITextView alloc] init];
	_textView.delegate = self;
	_textView.frame = CGRectMake(5.0f, 40.0f, 290.0f, 200.0f);
	_textView.font = [UIFont systemFontOfSize:16.0f];
	_textView.layer.borderColor = [UIColor grayColor].CGColor;
	_textView.layer.cornerRadius = 5.0f;
	_textView.layer.borderWidth = 5.0f;
	_wordCount = [[UILabel alloc] init];
	_wordCount.frame = CGRectMake(250.0f, 170.0f, 30.0f, 20.0f);
	_wordCount.font = [UIFont systemFontOfSize:16.0f];
	_wordCount.textColor = [UIColor grayColor];
	[_textView addSubview:_wordCount];
	[self addSubview:_textView];
	[self calculateTextLength];
    return self;
}

- (void) Show:(BOOL)animated
{
	self.frame = CGRectMake(10.0f, 100.0f, 300.0f, 280.0f); 
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	if (!window)
    {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
	[window addSubview:_backGroundView];
  	[window addSubview:self];
	_titleLable.text = _videoInfo.title;
	[self addObservers];
    	
}

- (void) Hide:(BOOL)animated
{
	[_backGroundView removeFromSuperview];
	[self removeFromSuperview];
	[self removeObservers];
}

#pragma mark Obeservers

- (void)addObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)removeObservers
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIKeyboardWillShowNotification" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIKeyboardWillHideNotification" object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
	[UIView beginAnimations:nil context:nil];
	self.frame = CGRectMake(10.0f, 0.0f, 300.0f, 280.0f);
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
	self.frame = CGRectMake(10.0f, 0.0f, 300.0f, 280.0f);    
}

#pragma mark - text length
- (int)textLength:(NSString *)text
{
    float number = 0.0;
    for (int index = 0; index < [text length]; index++)
    {
        NSString *character = [text substringWithRange:NSMakeRange(index, 1)];
        
        if ([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3)
        {
            number++;
        }
        else
        {
            number = number + 0.5;
        }
    }
    return ceil(number);
}

#pragma mark - UITextViewDelegate Methods

- (void)calculateTextLength
{
	int wordcount = [self textLength:_textView.text];
	NSInteger count  = 130 - wordcount;
	if(wordcount <= 0)
	{
		_sendButton.enabled = NO;
		_wordCount.textColor = [UIColor grayColor];		
	}
	else if (count < 0)
    {
		_sendButton.enabled = NO;
		_wordCount.textColor = [UIColor redColor];
	}
	else
    {
		_wordCount.textColor = [UIColor redColor];
		_sendButton.enabled = YES;
	}
	
	[_wordCount setText:[NSString stringWithFormat:@"%i",count]];
}


- (void)textViewDidChange:(UITextView *)textView
{
	[self calculateTextLength];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{	
    return YES;
}

- (IBAction)sendSinaWeiBo:(id)sender 
{
	NSString* text = [[NSString alloc] initWithFormat:@"%@%@", _textView.text, _videoInfo.itemUrl];
	NSString* annotation = [[NSString alloc] initWithFormat:@"[\"%@\"]", _videoInfo.itemCode];
	[_weiBoSDK sendWeiBo:text Annotations:annotation Delegate:_weiboDelegate];
	[self Hide:YES];
	
}

- (IBAction)cancelSendWeiBo:(id)sender 
{
	[self Hide:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

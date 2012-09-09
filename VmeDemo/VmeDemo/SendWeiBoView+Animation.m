//
//  SendWeiBoView+Animation.m
//  VmeDemo
//
//  Created by user on 12-6-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SendWeiBoView+Animation.h"
#import "ImageManager.h"
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CATransaction.h>
#import <QuartzCore/CAMediaTimingFunction.h>
static CALayer* left = nil;
static CALayer* right = nil;
static CALayer* envelopLayer = nil;
const static float ShowAnimationTime = 0.3f;
@implementation SendWeiBoView (Animation)

- (void) beginShowAnimation
{

	if (nil == left || nil == right) 
	{
		UIGraphicsBeginImageContext(CGSizeMake(self.layer.frame.size.width , self.layer.frame.size.height));
		[self.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		CGSize iamgeSize = image.size;
		CGImageRef leftImageRef = 
		CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0.f, 0.f, iamgeSize.width / 2.f, iamgeSize.height));
		CGImageRef rightImageRef = 
		CGImageCreateWithImageInRect(image.CGImage, CGRectMake(iamgeSize.width / 2.f, 0, iamgeSize.width / 2.f, iamgeSize.height));
		left = [[CALayer alloc] init];
		left.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, iamgeSize.width / 2.0f, iamgeSize.height);
		left.contents = (__bridge_transfer id)leftImageRef;
		right = [[CALayer alloc] init];
		right.frame = CGRectMake(self.frame.origin.x + image.size.width / 2.f, self.frame.origin.y, iamgeSize.width / 2.0f, iamgeSize.height );
		right.contents = (__bridge_transfer id)rightImageRef;

	}
	[self.layer.superlayer addSublayer:left];
	self.hidden = YES;

	
	CABasicAnimation* theAnimation;
	theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
	theAnimation.duration= ShowAnimationTime;
	theAnimation.repeatCount=0;
	theAnimation.autoreverses=NO;
	theAnimation.fromValue=[NSNumber numberWithFloat:3.14f / 2.0f];
	theAnimation.toValue=[NSNumber numberWithFloat:0.f];
    theAnimation.removedOnCompletion    = NO;
	theAnimation.delegate = self;
	theAnimation.removedOnCompletion = YES;
	[theAnimation setValue:@"leftRotation" forKey:@"name"];
	CGRect frame = left.frame;
	left.anchorPoint = CGPointMake(1.0f, 0.0f);
	left.frame = frame;

	[left addAnimation:theAnimation forKey:@"leftRotation"];
}

- (void)beginRightAnimation
{
	[left.superlayer addSublayer:right];
	CABasicAnimation* theAnimation;
	theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
	theAnimation.duration = ShowAnimationTime;
	theAnimation.repeatCount = 0;
	theAnimation.autoreverses = NO;
	theAnimation.fromValue = [NSNumber numberWithFloat:-3.14f / 2.0f];
	theAnimation.toValue = [NSNumber numberWithFloat:0.f];
    theAnimation.removedOnCompletion = YES;
	theAnimation.delegate = self;
	[theAnimation setValue:@"rightRotation" forKey:@"name"];
	CGRect frame = right.frame;
	right.anchorPoint = CGPointMake(0.0f, 0.0f);
	right.frame = frame;
	[right addAnimation:theAnimation forKey:@"rightRotation"];
}

- (void) beginSendAnimation
{
	if(nil == envelopLayer)
	{
		envelopLayer = [[CALayer alloc] init];
		envelopLayer.frame = self.layer.frame;
		UIImage* image = [[ImageManager sharedImageManager]getImageFromBundle:@"send.png"];
		envelopLayer.contents = (__bridge_transfer id)image.CGImage;
	}
	[self.layer.superlayer addSublayer:envelopLayer];
	envelopLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
	envelopLayer.frame = self.layer.frame;
	envelopLayer.transform = CATransform3DIdentity;
	envelopLayer.hidden = NO;
	
	CABasicAnimation*  theAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	theAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
    theAnimation.toValue        = [NSNumber numberWithFloat:0.0f];;
    theAnimation.duration        = ShowAnimationTime;
    theAnimation.autoreverses    = NO;
	[self.layer addAnimation:theAnimation forKey:@"showEnvelop"];
	
	theAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	theAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    theAnimation.toValue        = [NSNumber numberWithFloat:1.0f];
    theAnimation.duration        = ShowAnimationTime;
    theAnimation.autoreverses    = NO;
    theAnimation.delegate        = self;
	[theAnimation setValue:@"envelopShow" forKey:@"name"];
	[envelopLayer addAnimation:theAnimation forKey:@"showEnvelop"];
}

- (void) TransformEnvelop
{
	CABasicAnimation*  theAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    theAnimation.toValue        = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.3, 0.3, 0.3)];
    theAnimation.duration        = ShowAnimationTime;
    theAnimation.autoreverses    = NO;
    theAnimation.delegate        = self;
	[theAnimation setValue:@"transformEnvelop" forKey:@"name"];
	[envelopLayer addAnimation:theAnimation forKey:@"transformEnvelop"];	
}

- (void) RemoveEnvelop
{
	CABasicAnimation*  theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    theAnimation.toValue        = [NSNumber numberWithFloat:1000.0f];
    theAnimation.duration        = 2 * ShowAnimationTime;
    theAnimation.autoreverses    = NO;
    theAnimation.delegate        = self;
	[theAnimation setValue:@"removeEnvelop" forKey:@"name"];
	[envelopLayer addAnimation:theAnimation forKey:@"RemoveEnvelop"];	
}

- (void) beginHideAnimation
{
	self.layer.hidden = YES;
	[self.layer.superlayer addSublayer:left];
	[self.layer.superlayer addSublayer:right];
	CABasicAnimation*  theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    theAnimation.toValue        = [NSNumber numberWithFloat:-500.0f];
    theAnimation.duration        = 2.1 * ShowAnimationTime;
    theAnimation.autoreverses    = NO;
	[left addAnimation:theAnimation forKey:@"RemoveEnvelop"];	
	
	theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    theAnimation.toValue        = [NSNumber numberWithFloat:500.0f];
    theAnimation.duration        = 2.1 * ShowAnimationTime;
    theAnimation.autoreverses    = NO;
    theAnimation.delegate        = self;
	[theAnimation setValue:@"hideAnimation" forKey:@"name"];
	[right addAnimation:theAnimation forKey:@"RemoveEnvelop"];
}

- (void) animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
	NSString* name = [animation valueForKey:@"name"];
	if ([name isEqualToString:@"leftRotation"]) 
	{
		[self performSelector:@selector(beginRightAnimation) withObject:nil afterDelay:0.1f];
	}
	else if ([name isEqualToString:@"rightRotation"]) 
	{
		//完成开始动画
		self.layer.hidden = NO;
		[left removeAllAnimations];
		[left removeFromSuperlayer];
		[right removeAllAnimations];
		[right removeFromSuperlayer];
	}
	else if([name isEqualToString:@"envelopShow"])
	{
		self.layer.hidden = YES;
		[self performSelector:@selector(TransformEnvelop) withObject:nil afterDelay:0.2f];
	}
	else if([name isEqualToString:@"transformEnvelop"])
	{
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		envelopLayer.transform = CATransform3DMakeScale(0.3f, 0.3f, 0.3f);	
		self.layer.hidden = YES;
		[CATransaction commit];
		[self performSelector:@selector(RemoveEnvelop) withObject:nil afterDelay:0.2f];
	}
	else if([name isEqualToString:@"removeEnvelop"])
	{
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		envelopLayer.hidden = YES;
		[CATransaction commit];
		[self OnSendAnnimateFinish];
	}
	else if([name isEqualToString:@"hideAnimation"])
	{
		[CATransaction begin];
		
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		self.layer.hidden = YES;
		[left removeFromSuperlayer];
		[right removeFromSuperlayer];
		[CATransaction commit];
		[self OnHideAnimateFinish];
	}
}

@end

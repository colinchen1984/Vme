//
//  ImageManager.m
//  VmeDemo
//
//  Created by user on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ImageManager.h"

@interface URLImageRequest : WebRequest
@property (copy, nonatomic) NSString* imageURL;
@property (weak, nonatomic) id<URLImageDelegate> urlImageDelegate;
@end

@implementation URLImageRequest
@synthesize imageURL = _imageURL;
@synthesize urlImageDelegate = _urlImageDelegate;

- (void) cancelRequest
{
	[super cancelRequest];
	_imageURL = nil;
	_urlImageDelegate = nil;
}
@end

static ImageManager* singleton = nil;

@interface ImageManager()
@property (strong, nonatomic) NSMutableDictionary* imageDic;
@property (strong, nonatomic) NSMutableDictionary* usingConnection;
@property (strong, nonatomic) NSMutableArray* freeConnection;
@end

@implementation ImageManager
@synthesize imageDic = _imageDic;
@synthesize usingConnection = _usingConnection;
@synthesize freeConnection = _freeConnection;

#pragma mark - Singleton
+(ImageManager*) sharedImageManager
{
	if (nil == singleton) {
		singleton = [[ImageManager alloc] init];
	}
	return singleton;
}

#pragma mark - life cycle
- (id) init
{
	self = [super init];
	if(nil == self)
	{
		return nil;
	}
	_imageDic = [[NSMutableDictionary alloc] init];
	_usingConnection = [[NSMutableDictionary alloc] init];
	_freeConnection = [[NSMutableArray alloc] init];
	return self;
}

#pragma mark - interface ImageManger
- (void) postURL2DownLoadImage:(NSString*) urlPath Delegate:(id<URLImageDelegate>)delegate
{
	UIImage* image = [_imageDic objectForKey:urlPath];
	if (nil != image) 
	{
		[delegate OnReceiveImage:image];
		return;
	}
	
	URLImageRequest* request = [self getFreeRequestByURL:urlPath];
	[request setDelegate:self];
	[request setUrlImageDelegate:delegate];
	[request setImageURL:urlPath];
	[request postUrlRequest:urlPath];
	return;
}

- (void) cancelURLDownLoadImage:(NSString*) urlPath
{
	URLImageRequest* request = [_usingConnection objectForKey:urlPath];
	if (nil != request) 
	{
		[self freeRequest:request URL:urlPath];	
	}
}

- (UIImage*) getImageFromBundle:(NSString*) fileName
{
	UIImage* image = [_imageDic objectForKey:fileName];
	if (nil == image) 
	{
		image = [UIImage imageNamed:fileName];
		[_imageDic setObject:image forKey:fileName];
	}

	return image;
}

#pragma mark - private interface for manger request
- (void) freeRequest:(URLImageRequest*) request URL:(NSString*)urlPath
{
	[_freeConnection addObject:request];
	[_usingConnection removeObjectForKey:urlPath];
	[request cancelRequest];
}

- (URLImageRequest*) getFreeRequestByURL:(NSString*)urlPath
{
	URLImageRequest* request = nil;
	int freeConnectionCount = [_freeConnection count];
	if (0 != freeConnectionCount)
	{
		request = [_freeConnection objectAtIndex:(freeConnectionCount - 1)];
		[_freeConnection removeObjectAtIndex:(freeConnectionCount - 1)];
	}
	else 
	{
		request = [[URLImageRequest alloc] init];
	}
	[_usingConnection setObject:request forKey:urlPath];
	return request;
}

#pragma mark - WebRequest Delegate Methods
- (void) OnReceiveData:(WebRequest*) request Data:(NSData*)data;

{
	URLImageRequest* urlImageRequest = (URLImageRequest*)request;
	UIImage* image = [[UIImage alloc] initWithData:data];
	if (nil == image) 
	{
		NSString* url = urlImageRequest.imageURL;
		id<URLImageDelegate> delegate = urlImageRequest.urlImageDelegate;
		[self freeRequest:urlImageRequest URL:urlImageRequest.imageURL];
		[self postURL2DownLoadImage:url Delegate:delegate];
	}
	else 
	{
		[_imageDic setObject:image forKey:[urlImageRequest imageURL]];
		[[urlImageRequest urlImageDelegate] OnReceiveImage:image];
		[self freeRequest:urlImageRequest URL:urlImageRequest.imageURL];
	}
}

- (void) OnReceiveError:(WebRequest*) request;
{
	URLImageRequest* urlImageRequest = (URLImageRequest*)request;
	//请勿调整顺序
	[self freeRequest:urlImageRequest URL:urlImageRequest.imageURL];
	[[urlImageRequest urlImageDelegate] OnReceiveError:[urlImageRequest imageURL]];
}

@end

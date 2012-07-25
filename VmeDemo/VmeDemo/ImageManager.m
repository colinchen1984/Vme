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

@end

@implementation ImageManager
@synthesize imageDic = _imageDic;

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
	return self;
}
- (NSString*) getMD5FromURL:(NSString*)url
{
	char result[33] = {0};
	const char* str = [url UTF8String];
	CC_MD5(str, strlen(str), result);
	NSString* r =  [NSString stringWithFormat: 
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7], 
            result[8], result[9], result[10], result[11], 
            result[12], result[13], result[14], result[15] 
            ]; 
	return r;
}

- (NSString*) pathInDocumentDirectory:(NSString*) fileName 
{
    // Get list of document directories in sandbox
    NSArray *documentDirectories = 
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                        NSUserDomainMask, YES);
    
    // Get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    // Append passed in file name to that directory, return it
    NSString* result = [documentDirectory stringByAppendingPathComponent:fileName];
	return result;
}

- (UIImage*) loadImageFromLocalDisk:(NSString*)fileNmae
{
	NSData* data = [NSData dataWithContentsOfFile:[self pathInDocumentDirectory:fileNmae]];
	
	UIImage* result = [UIImage imageWithData:data];
	return result;
}

- (void) writeImageToLocalDisk:(NSString*)fileName Image:(NSData*)imageData
{
	[imageData writeToFile:[self pathInDocumentDirectory:fileName] atomically:YES];
}

#pragma mark - interface ImageManger
- (void) postURL2DownLoadImage:(NSString*) urlPath Delegate:(id<URLImageDelegate>)delegate
{
	if(nil == urlPath || nil == delegate)
	{
		return;
	}
	
	NSString* md5name = [self getMD5FromURL:urlPath];
	UIImage* image = [_imageDic objectForKey:md5name];
	if (nil != image) 
	{
		[delegate OnReceiveImage:image ImageUrl:urlPath];
		return;
	}
	image = [self loadImageFromLocalDisk:md5name];
	if (nil != image) 
	{
		[_imageDic setObject:image forKey:md5name];
		[delegate OnReceiveImage:image ImageUrl:urlPath];
		return;
	}
	
	URLImageRequest* request = [[URLImageRequest alloc] init];
	request.imageURL = urlPath;
	request.urlImageDelegate = delegate;
	request.delegate = self;
	[request setUrlImageDelegate:delegate];
	[request setImageURL:urlPath];
	[request postUrlRequest:urlPath];
	return;
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


#pragma mark - WebRequest Delegate Methods
- (void) OnReceiveData:(WebRequest*) request Data:(NSData*)data;

{
	URLImageRequest* urlImageRequest = (URLImageRequest*)request;
	UIImage* image = [[UIImage alloc] initWithData:data];
	if (nil == image) 
	{
		NSString* url = urlImageRequest.imageURL;
		id<URLImageDelegate> delegate = urlImageRequest.urlImageDelegate;
		[self postURL2DownLoadImage:url Delegate:delegate];
	}
	else 
	{
		[_imageDic setObject:image forKey:urlImageRequest.imageURL];
		[self writeImageToLocalDisk:[self getMD5FromURL:urlImageRequest.imageURL] Image:data];
		[[urlImageRequest urlImageDelegate] OnReceiveImage:image ImageUrl:urlImageRequest.imageURL];
	}
}

- (void) OnReceiveError:(WebRequest*) request;
{
	URLImageRequest* urlImageRequest = (URLImageRequest*)request;
	//请勿调整顺序
	[[urlImageRequest urlImageDelegate] OnReceiveError:[urlImageRequest imageURL]];
}

@end

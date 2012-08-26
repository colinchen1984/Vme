//
//  WebRequest.m
//  VmeDemo
//
//  Created by user on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WebRequest.h"
#import "Utility.h"

@interface WebRequest()
@property (strong, nonatomic) NSURLConnection* connection;
@property (strong, nonatomic) NSMutableData* data;
@property (strong, nonatomic) NSString* debugStr;
@end

@implementation WebRequest
@synthesize connection = _connection;
@synthesize delegate = _delegate;
@synthesize data = _data;
@synthesize debugStr = _debugStr;
@synthesize httpMethod = _httpMethod;
@synthesize httpBody = _httpBody;
@synthesize httpHead = _httpParam;


#pragma mark - lefe cycle
- (id) init
{
  	if (nil == self)
	{
		return nil;
	}
	_connection = nil;
	_delegate = nil;
	_data = nil;
	_httpMethod = @"GET";
	_data = [[NSMutableData alloc] init];
	return self;
}
    
#pragma mark - process http header and body
+ (NSString *)stringFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in [dict keyEnumerator])
	{
		if (!([[dict valueForKey:key] isKindOfClass:[NSString class]]))
		{
			continue;
		}
		
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [[dict objectForKey:key] URLEncodedString]]];
	}
	
	return [pairs componentsJoinedByString:@"&"];
}

+ (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString
{
    [body appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod
{
    if (![httpMethod isEqualToString:@"GET"])
    {
        return baseURL;
    }
    
    NSURL *parsedURL = [NSURL URLWithString:baseURL];
	NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
	NSString *query = [WebRequest stringFromDictionary:params];
	
	return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}

- (NSMutableData *)postBody
{
    NSMutableData *body = [NSMutableData data];
    
	[WebRequest appendUTF8Body:body dataString:[WebRequest stringFromDictionary:_httpBody]];
	return body;
}

#pragma mark - post url request
- (void) postUrlRequest:(NSString *)url
{

	_debugStr = [WebRequest serializeURL:url params:_httpParam httpMethod:_httpMethod];
	NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_debugStr]
												cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
											timeoutInterval:60.0];
	[urlRequest setHTTPMethod:_httpMethod];
	if (YES != [_httpMethod isEqualToString:@"GET"]) 
	{
		[urlRequest setHTTPBody:[self postBody]];
	}

	
/*	for (NSString *key in [_httpHeader keyEnumerator])
    {
        [urlRequest setValue:[_httpHeader objectForKey:key] forHTTPHeaderField:key];
    }
*/
	
	NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest: urlRequest
																  delegate: self
														  startImmediately: YES];
	_connection = connection;
	
}

- (void) cancelRequest
{
	[_connection cancel];
	self.connection = nil;
	self.delegate = nil;
	self.httpHead = nil;
	self.httpBody = nil;
	self.httpMethod = @"GET";
	self.debugStr = nil;
	[_data setLength:0];
}

#pragma mark - NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[_data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{	
	[_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection 
{
	[_delegate OnReceiveData:self Data:_data];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
	[_delegate OnReceiveError:self];
}

@end


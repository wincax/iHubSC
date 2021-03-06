//
//  GHAPIBackgroundQueueV3.m
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIBackgroundQueueV3.h"

#import "GithubAPI.h"

dispatch_queue_t GHAPIBackgroundQueue() {
    return [GHAPIBackgroundQueueV3 sharedInstance].backgroundQueue;
}

@implementation GHAPIBackgroundQueueV3

@synthesize remainingAPICalls=_remainingAPICalls;

- (dispatch_queue_t)backgroundQueue {
    if (!_backgroundQueue) {
        _backgroundQueue = dispatch_queue_create("de.olettere.GHAPIV3.backgroundQueue", NULL);
    }
    return _backgroundQueue;
}

- (dispatch_queue_t)imageQueue {
    if (!_imageQueue) {
        _imageQueue = dispatch_queue_create("de.olettere.GHAPIV3.imageQueue", NULL);
    }
    return _imageQueue;
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        _remainingAPICalls = 5000;
    }
    return self;
}

#pragma mark - instance methods

- (void)sendRequestToURL:(NSURL *)URL 
            setupHandler:(void(^)(ASIFormDataRequest *request))setupHandler 
       completionHandler:(void(^)(id object, NSError *error, ASIFormDataRequest *request))completionHandler {
    
    dispatch_async(self.backgroundQueue, ^(void) {
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        request.requestMethod = @"GET";
        
//        NSMutableDictionary *requestHeaders = request.requestHeaders;
//        if (!requestHeaders) {
//            requestHeaders = [NSMutableDictionary dictionary];
//            request.requestHeaders = requestHeaders;
//        }
        [request addRequestHeader:@"spenc" value:@"UTF-8"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
//        [request.requestHeaders setObject:@"UTF-8" forKey:@"spenc"];
//        [request.requestHeaders setObject:@"application/json" forKey:@"Accept"];
        
        if (setupHandler) setupHandler(request);
        
        [request startSynchronous];
        
        NSString *responseString = [[NSString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding];
        id responseObject = responseString.objectFromJSONString;
        
        NSString *XRatelimitRemaing = [[request responseHeaders] objectForKey:@"X-RateLimit-Remaining"];
        _remainingAPICalls = [XRatelimitRemaing integerValue];
        
        myError = [request error];
        
        if (!myError) {
            myError = [NSError errorFromRawDictionary:responseObject];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                DLog(@"error in URL (%@):\n%@", URL, myError);
                DLog(@"%@", responseObject);
                completionHandler(nil, myError, request);
            } else {
                completionHandler(responseObject, nil, request);
            }
        });
        
    });
    
}

- (void)sendRequestToURL:(NSURL *)URL page:(NSUInteger)page setupHandler:(void (^)(ASIFormDataRequest *))setupHandler completionPaginationHandler:(void (^)(id, NSError *, ASIFormDataRequest *, NSUInteger))completionHandler {
    
    NSString *urlString = [URL absoluteString];
    if ([urlString rangeOfString:@"?"].location == NSNotFound) {
        urlString = [urlString stringByAppendingString:@"?"];
    } else if (![urlString hasSuffix:@"&"]) {
        urlString = [urlString stringByAppendingString:@"&"];
    }
    urlString = [urlString stringByAppendingFormat:@"page=%d&per_page=%d", page, GHAPIDefaultPaginationCount];
    URL = [NSURL URLWithString:urlString];
    
    [self sendRequestToURL:URL 
              setupHandler:setupHandler 
         completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
             NSString *linkHeader = [[request responseHeaders] objectForKey:@"Link"];
             completionHandler(object, error, request, linkHeader.nextPage);
         }];
}

@end





#pragma mark - Singleton implementation

static GHAPIBackgroundQueueV3 *_instance = nil;

@implementation GHAPIBackgroundQueueV3 (Singleton)

+ (GHAPIBackgroundQueueV3 *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+ (id)allocWithZone:(NSZone *)zone {	
	return [self sharedInstance];	
}


- (id)copyWithZone:(NSZone *)zone {
    return self;	
}

@end

//
//  GHAPIPullRequestV3.m
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIPullRequestV3.h"
#import "GithubAPI.h"

@implementation GHAPIPullRequestV3

+ (void)mergPullRequestOnRepository:(NSString *)repository 
                         withNumber:(NSNumber *)pullRequestNumber 
                      commitMessage:(NSString *)commitMessage 
                  completionHandler:(void(^)(GHAPIPullRequestMergeStateV3 *state, NSError *error))handler 
{
    // v3: PUT /repos/:user/:repo/pulls/:id/merge
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/pulls/%@/merge",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                       pullRequestNumber ]];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"PUT"];
                                                
                                                NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObject:commitMessage 
                                                                                                           forKey:@"commit_message"];
                                                
                                                NSString *jsonString = [jsonDictionary JSONString];
                                                NSMutableData *jsonData = [[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                                                [request setPostBody:jsonData];
                                                [request setPostLength:[jsonString length] ];
                                            }
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               handler([[GHAPIPullRequestMergeStateV3 alloc] initWithRawDictionary:object], nil);
                                           }
                                       }];
}

+ (void)commitsOfPullRequestOnRepository:(NSString *)repository 
                              withNumber:(NSNumber *)pullRequestNumber 
                       completionHandler:(void(^)(NSArray *commits, NSError *error))completionHandler
{
    // v3: GET /repos/:user/:repo/pulls/:id/commits
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/pulls/%@/commits",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                       pullRequestNumber ]];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                 setupHandler:nil
                                            completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                if (error) {
                                                    completionHandler(nil, error);
                                                } else {
                                                    NSArray *rawArray = GHAPIObjectExpectedClass(&object, NSArray.class);
                                                    
                                                    NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                                    for (NSDictionary *rawDictionary in rawArray) {
                                                        [finalArray addObject:[[GHAPICommitV3 alloc] initWithRawDictionary:rawDictionary] ];
                                                    }
                                                    
                                                    completionHandler(finalArray, nil);
                                                }
                                            }];
}

@end

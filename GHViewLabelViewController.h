//
//  GHViewLabelViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GithubAPI.h"

@interface GHViewLabelViewController : GHTableViewController {
@private
    NSString *_repositoryString;
    GHAPILabelV3 *_label;
    
    NSArray *_openIssues;
    NSInteger _openIssuesNextPage;
    
    NSArray *_closedIssues;
    NSInteger _closedIssuesNextPage;
}

@property (nonatomic, copy) NSString *repositoryString;
@property (nonatomic, retain) GHAPILabelV3 *label;

@property (nonatomic, retain) NSArray *openIssues;
@property (nonatomic, retain) NSArray *closedIssues;

- (id)initWithRepository:(NSString *)repository label:(GHAPILabelV3 *)label;

- (void)cacheHeightForOpenIssuesArray;
- (void)cacheHeightForClosedIssuesArray;

@end

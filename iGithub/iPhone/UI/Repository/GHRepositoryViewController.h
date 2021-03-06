//
//  GHSingleRepositoryViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 09.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHActionButtonTableViewController.h"
#import "GithubAPI.h"
#import "GHCreateIssueTableViewController.h"
#import "GHCreateMilestoneViewController.h"
#import "SVModalWebViewController.h"

@class GHRepositoryViewController;

@protocol GHSingleRepositoryViewControllerDelegate <NSObject>

- (void)singleRepositoryViewControllerDidDeleteRepository:(GHRepositoryViewController *)singleRepositoryViewController;

@end

@interface GHRepositoryViewController : GHActionButtonTableViewController <UIAlertViewDelegate, GHSingleRepositoryViewControllerDelegate, GHCreateIssueTableViewControllerDelegate, GHCreateMilestoneViewControllerDelegate, SVModalWebViewControllerDelegate> {
@private
    NSString *_repositoryString;
    GHAPIRepositoryV3 *_repository;
    
    BOOL _hasWatchingData;
    BOOL _isWatchingRepository;
    
    NSString *_deleteToken;
    
    id<GHSingleRepositoryViewControllerDelegate> __weak _delegate;
    
    NSMutableArray *_pullRequests;
    
    NSMutableArray *_branches;
    NSMutableArray *_labels;
    NSMutableArray *_milestones;
    NSMutableArray *_organizations;
    NSMutableArray *_issuesArray;
    NSMutableArray *_watchedUsersArray;
    NSMutableArray *_collaborators;
    
    UIColor *_labelColor;
}

@property (nonatomic, readonly) BOOL isFollowingRepository;
@property (nonatomic, readonly) BOOL canAdministrateRepository;

@property (nonatomic, copy) NSString *repositoryString;
@property (nonatomic, retain) GHAPIRepositoryV3 *repository;

@property (nonatomic, retain) NSMutableArray *issuesArray;
- (void)cacheHeightForIssuesArray;

@property (nonatomic, retain) NSMutableArray *milestones;

@property (nonatomic, retain) NSMutableArray *watchedUsersArray;

@property (nonatomic, copy) NSString *deleteToken;
@property (nonatomic, weak) id<GHSingleRepositoryViewControllerDelegate> delegate;

@property (nonatomic, retain) NSMutableArray *pullRequests;
- (void)cacheHeightForPullRequests;

@property (nonatomic, retain) NSMutableArray *branches;
@property (nonatomic, retain) NSMutableArray *labels;
@property (nonatomic, retain) NSMutableArray *organizations;
@property (nonatomic, retain) NSMutableArray *collaborators;

- (id)initWithRepositoryString:(NSString *)repositoryString;

- (void)organizationsActionSheetDidSelectOrganizationAtIndex:(NSUInteger)index;

@end

//
//  GHUserViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GHCreateRepositoryViewController.h"
#import "GHSingleRepositoryViewController.h"
#import "UIExpandableTableView.h"
#import "GithubAPI.h"

@interface GHUserViewController : GHTableViewController <GHCreateRepositoryViewControllerDelegate, GHSingleRepositoryViewControllerDelegate, UIAlertViewDelegate> {
@private
    NSString *_username;
    BOOL _isDownloadingUserData;
    GHUser *_user;
    
    NSArray *_repositoriesArray;
    NSArray *_watchedRepositoriesArray;
    NSArray *_followingUsers;
    NSArray *_organizations;
    NSMutableArray *_followedUsers;
    NSArray *_gists;
    NSUInteger _gistsNextPage;
    
    NSIndexPath *_lastIndexPathForSingleRepositoryViewController;
}

@property (nonatomic, retain) GHUser *user;

@property (nonatomic, retain) NSArray *repositoriesArray;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, retain) NSArray *watchedRepositoriesArray;
@property (nonatomic, retain) NSArray *followingUsers;
@property (nonatomic, retain) NSArray *organizations;
@property (nonatomic, retain) NSMutableArray *followedUsers;
@property (nonatomic, retain) NSArray *gists;

@property (nonatomic, readonly) BOOL canFollowUser;
@property (nonatomic, readonly) BOOL isFollowingUser;

@property (nonatomic, copy) NSIndexPath *lastIndexPathForSingleRepositoryViewController;

- (id)initWithUsername:(NSString *)username;

- (void)createRepositoryButtonClicked:(UIBarButtonItem *)button;
- (void)accountButtonClicked:(UIBarButtonItem *)button;

- (void)downloadUserData;
- (void)downloadRepositories;
- (void)cacheHeightForTableView;
- (void)cacheHeightForWatchedRepositories;
- (void)cacheGistsHeight;

@end

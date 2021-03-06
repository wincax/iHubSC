//
//  GHViewMilestoneViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GithubAPI.h"
#import "GHActionButtonTableViewController.h"
#import "GHUpdateMilestoneViewController.h"

@interface GHMilestoneViewController : GHActionButtonTableViewController <GHCreateMilestoneViewControllerDelegate> {
@private
    GHAPIMilestoneV3 *_milestone;
    
    NSString *_repository;
    NSNumber *_milestoneNumber;
    
    NSMutableArray *_openIssues;
    NSMutableArray *_closedIssues;
    
    BOOL _hasCollaboratorData;
    BOOL _isCollaborator;
}

@property (nonatomic, retain) GHAPIMilestoneV3 *milestone;

@property (nonatomic, copy) NSString *repository;
@property (nonatomic, copy) NSNumber *milestoneNumber;

@property (nonatomic, retain) NSMutableArray *openIssues;
@property (nonatomic, retain) NSMutableArray *closedIssues;

- (id)initWithRepository:(NSString *)repository milestoneNumber:(NSNumber *)milestoneNumber;

- (void)downloadMilestoneData;

- (void)cacheHeightForOpenIssuesArray;
- (void)cacheHeightForClosedIssuesArray;

@end

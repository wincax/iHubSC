//
//  GHCreateIssueTableViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 14.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GithubAPI.h"
#import "GHCreateIssueTableViewCell.h"

extern NSInteger const kGHCreateIssueTableViewControllerSectionTitle;
extern NSInteger const kGHCreateIssueTableViewControllerSectionAssignee;
extern NSInteger const kGHCreateIssueTableViewControllerSectionMilestones;



@class GHCreateIssueTableViewController;

@protocol GHCreateIssueTableViewControllerDelegate <NSObject>

- (void)createIssueViewController:(GHCreateIssueTableViewController *)createViewController didCreateIssue:(GHAPIIssueV3 *)issue;
- (void)createIssueViewControllerDidCancel:(GHCreateIssueTableViewController *)createViewController;

@end



@interface GHCreateIssueTableViewController : GHTableViewController {
@private
    id<GHCreateIssueTableViewControllerDelegate> __weak _delegate;
    NSString *_repository;
    
    NSMutableArray *_collaborators;
    NSString *_assigneeString;
    
    BOOL _hasCollaboratorState;
    BOOL _isCollaborator;
    
    NSMutableArray *_milestones;
    NSNumber *_selectedMilestoneNumber;
}

@property (nonatomic, weak) id<GHCreateIssueTableViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *repository;

@property (nonatomic, retain) NSMutableArray *collaborators;
@property (nonatomic, retain) NSMutableArray *milestones;

@property (nonatomic, copy) NSString *assigneeString;
@property (nonatomic, copy) NSNumber *selectedMilestoneNumber;



- (void)cancelButtonClicked:(UIBarButtonItem *)sender;
- (void)saveButtonClicked:(UIBarButtonItem *)sender;

- (id)initWithRepository:(NSString *)repository;

@end

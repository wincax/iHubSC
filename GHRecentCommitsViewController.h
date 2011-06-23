//
//  GHRecentCommitsViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 17.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@interface GHRecentCommitsViewController : GHTableViewController {
@private
    NSString *_repository;
    NSString *_branch;
    NSString *_branchHash;
    
    NSMutableArray *_commits;
}

@property (nonatomic, copy) NSString *repository;
@property (nonatomic, copy) NSString *branch;
@property (nonatomic, retain) NSMutableArray *commits;
@property (nonatomic, copy) NSString *branchHash;

- (id)initWithRepository:(NSString *)repository branch:(NSString *)branch;

- (void)downloadCommitData;
- (void)cacheHeightsForCommits;

@end

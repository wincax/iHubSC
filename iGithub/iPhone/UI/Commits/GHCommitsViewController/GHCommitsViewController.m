//
//  GHRecentCommitsViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 17.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCommitsViewController.h"
#import "GithubAPI.h"
#import "GHDescriptionTableViewCell.h"
#import "GHViewCommitViewController.h"
#import "SVModalWebViewController.h"

@interface GHCommitsViewController () <SVModalWebViewControllerDelegate>

@end

@implementation GHCommitsViewController
@synthesize repository=_repository, branch=_branch, commits=_commits, branchHash=_branchHash;

#pragma mark - setters and getters

- (void)setCommits:(NSMutableArray *)commits
{
    if (commits != _commits) {
        _commits = commits;
        
        [self cacheHeightsForCommits];
        
        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository branchName:(NSString *)branchName branchHash:(NSString *)branchHash 
{
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.title = NSLocalizedString(@"Recent Commits", @"");
        self.repository = repository;
        self.branch = branchName;
        self.branchHash = branchHash;
        self.isDownloadingEssentialData = YES;
        [self downloadCommitData];
    }
    return self;
}

- (id)initWithRepository:(NSString *)repository commits:(NSArray *)commits
{
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.title = NSLocalizedString(@"Commits", @"");
        self.repository = repository;
        self.commits = commits.mutableCopy;
    }
    return self;
}

#pragma mark - pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    [GHAPIRepositoryV3 commitsOnRepository:self.repository branchSHA:self.branchHash page:page 
                         completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 [self setNextPage:nextPage forSection:0];
                                 [self.commits addObjectsFromArray:array];
                                 [self cacheHeightsForCommits];
                                 [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                               withRowAnimation:UITableViewRowAnimationAutomatic];
                             }
                         }];
}

#pragma mark - downloading data

- (void)downloadCommitData {
    [GHAPIRepositoryV3 commitsOnRepository:self.repository branchSHA:self.branchHash page:1 
                         completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                             self.isDownloadingEssentialData = NO;
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 [self setNextPage:nextPage forSection:0];
                                 self.commits = array;
                                 [self cacheHeightsForCommits];
                                 [self.tableView reloadData];
                             }
                         }];
}

- (void)cacheHeightsForCommits {
    NSInteger i = 0;
    for (GHAPICommitV3 *commit in self.commits) {
        [self cacheHeight:[GHDescriptionTableViewCell heightWithContent:commit.message] forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] ];
        i++;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.commits) {
        return 0;
    }
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.commits count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
    GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    GHAPICommitV3 *commit = [self.commits objectAtIndex:indexPath.row];
    
    [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:commit.author.avatarURL];
    
    NSString *username = commit.author.login ? commit.author.login : commit.author.name;
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ committed %@", @""), username, commit.SHA];
    cell.descriptionLabel.text = commit.message;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cachedHeightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHAPICommitV3 *commit = [self.commits objectAtIndex:indexPath.row];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/%@/commit/%@", _repository, commit.SHA]];
    
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithURL:URL];
    webViewController.webDelegate = self;
    [self presentViewController:webViewController animated:YES completion:nil];
}

#pragma mark - SVModalWebViewControllerDelegate

- (void)modalWebViewControllerIsDone:(SVModalWebViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_branch forKey:@"branch"];
    [encoder encodeObject:_branchHash forKey:@"branchHash"];
    [encoder encodeObject:_commits forKey:@"commits"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _repository = [decoder decodeObjectForKey:@"repository"];
        _branch = [decoder decodeObjectForKey:@"branch"];
        _branchHash = [decoder decodeObjectForKey:@"branchHash"];
        _commits = [decoder decodeObjectForKey:@"commits"];
    }
    return self;
}

@end

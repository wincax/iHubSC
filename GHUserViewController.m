//
//  GHUserViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHUserViewController.h"
#import "GithubAPI.h"
#import "GHFeedItemWithDescriptionTableViewCell.h"
#import "UICollapsingAndSpinningTableViewCell.h"
#import "GHSingleRepositoryViewController.h"
#import "GHWebViewViewController.h"
#import "NSString+Additions.h"

#define kUITableViewSectionUserData 0
#define kUITableViewSectionRepositories 1
#define kUITableViewSectionWatchedRepositories 2
#define kUITableViewSectionPlan 3

@implementation GHUserViewController

@synthesize repositoriesArray=_repositoriesArray;
@synthesize username=_username, user=_user;
@synthesize watchedRepositoriesArray=_watchedRepositoriesArray;
@synthesize lastIndexPathForSingleRepositoryViewController=_lastIndexPathForSingleRepositoryViewController;

#pragma mark - setters and getters

- (void)setUsername:(NSString *)username {
    [_username release];
    _username = [username copy];
    self.title = self.username;
    
    self.watchedRepositoriesArray = nil;
    self.repositoriesArray = nil;
    self.user = nil;
    
    [self downloadUserData];
    [self.tableView reloadData];
}

#pragma mark - Initialization

- (id)initWithUsername:(NSString *)username {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.pullToReleaseEnabled = YES;
        self.username = username;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repositoriesArray release];
    [_username release];
    [_watchedRepositoriesArray release];
    [_lastIndexPathForSingleRepositoryViewController release];
    [_user release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - target actions

- (void)createRepositoryButtonClicked:(UIBarButtonItem *)button {
    GHCreateRepositoryViewController *createViewController = [[[GHCreateRepositoryViewController alloc] init] autorelease];
    createViewController.delegate = self;
    
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:createViewController] autorelease];
    [self presentModalViewController:navController animated:YES];
}

#pragma mark - instance methods

- (void)downloadUserData {
    _isDownloadingUserData = YES;
    [GHUser userWithName:self.username 
       completionHandler:^(GHUser *user, NSError *error) {
           _isDownloadingUserData = NO;
           if (error) {
               [self handleError:error];
           } else {
               self.user = user;
               [self didReloadData];
               [self.tableView reloadData];
           }
       }];
}

- (void)downloadRepositories {
    [GHRepository repositoriesForUserNamed:self.username 
                         completionHandler:^(NSArray *array, NSError *error) {
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 self.repositoriesArray = array;
                             }
                             [self cacheHeightForTableView];
                             [self didReloadData];
                             [self.tableView reloadData];
                         }];
}

- (void)reloadData {
    [self downloadUserData];
    self.repositoriesArray = nil;
    [self.tableView collapseSection:kUITableViewSectionRepositories animated:YES];
    self.watchedRepositoriesArray = nil;
    [self.tableView collapseSection:kUITableViewSectionWatchedRepositories animated:YES];
}

- (void)cacheHeightForTableView {
    NSInteger i = 0;
    for (GHRepository *repo in self.repositoriesArray) {
        CGFloat height = [self heightForDescription:repo.desctiptionRepo] + 50.0;
        
        if (height < 71.0) {
            height = 71.0;
        }
        
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:kUITableViewSectionRepositories]];
        
        i++;
    }
}

- (void)cacheHeightForWatchedRepositories {
    NSInteger i = 0;
    for (GHRepository *repo in self.watchedRepositoriesArray) {
        CGFloat height = [self heightForDescription:repo.desctiptionRepo] + 50.0;
        
        if (height < 71.0) {
            height = 71.0;
        }
        
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:kUITableViewSectionWatchedRepositories]];
        
        i++;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[GHAuthenticationManager sharedInstance].username isEqualToString:self.username]) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                                                target:self 
                                                                                                action:@selector(createRepositoryButtonClicked:)]
                                                  autorelease];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section == kUITableViewSectionRepositories || section == kUITableViewSectionWatchedRepositories || section == kUITableViewSectionPlan;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionRepositories) {
        return self.repositoriesArray == nil;
    } else if (section == kUITableViewSectionWatchedRepositories) {
        return self.watchedRepositoriesArray == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    NSString *CellIdientifier = @"UICollapsingAndSpinningTableViewCell";
    
    UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
    
    if (cell == nil) {
        cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier] autorelease];
    }
    
    if (section == kUITableViewSectionRepositories) {
        NSInteger numberOfRepositories = self.user.publicRepoCount + self.user.privateRepoCount;
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Repositories (%d)", @""), numberOfRepositories];
    } else if (section == kUITableViewSectionWatchedRepositories) {
        cell.textLabel.text = NSLocalizedString(@"Watched Repositories", @"");
    } else if (section == kUITableViewSectionPlan) {
        cell.textLabel.text = NSLocalizedString(@"Plan", @"");
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionRepositories) {
        [GHRepository repositoriesForUserNamed:self.username 
                             completionHandler:^(NSArray *array, NSError *error) {
                                 if (error) {
                                     [self handleError:error];
                                 } else {
                                     self.repositoriesArray = array;
                                     [self cacheHeightForTableView];
                                     [self.tableView expandSection:section animated:YES];
                                 }
                                 [self didReloadData];
                             }];
    } else if (section == kUITableViewSectionWatchedRepositories) {
        [GHRepository watchedRepositoriesOfUser:self.username 
                              completionHandler:^(NSArray *array, NSError *error) {
                                  if (error) {
                                      [self handleError:error];
                                  } else {
                                      self.watchedRepositoriesArray = array;
                                      [self cacheHeightForWatchedRepositories];
                                      [self.tableView expandSection:section animated:YES];
                                  }
                              }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_isDownloadingUserData || !self.user) {
        return 0;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger result = 0;
    
    if (section == kUITableViewSectionUserData) {
        result = 5;
    } else if (section == kUITableViewSectionRepositories) {
        result = [self.repositoriesArray count] + 1;
    } else if (section == kUITableViewSectionWatchedRepositories) {
        // watched
        result = [self.watchedRepositoriesArray count] + 1;
    } else if (section == kUITableViewSectionPlan && self.user.planName) {
        result = 5;
    }
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionUserData) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"TitleTableViewCell";
            
            GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellEditingStyleNone;
            }
            
            cell.titleLabel.text = self.user.login;
            cell.descriptionLabel.text = nil;
            cell.repositoryLabel.text = nil;
            
            [self updateImageViewForCell:cell atIndexPath:indexPath withGravatarID:self.user.gravatarID];
            
            return cell;
        } else {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"E-Mail", @"");
                cell.detailTextLabel.text = self.user.EMail ? self.user.EMail : @"-";
            } else if (indexPath.row == 2) {
                cell.textLabel.text = NSLocalizedString(@"Location", @"");
                cell.detailTextLabel.text = self.user.location ? self.user.location : @"-";
            } else if (indexPath.row == 3) {
                cell.textLabel.text = NSLocalizedString(@"Company", @"");
                cell.detailTextLabel.text = self.user.company ? self.user.company : @"-";
            } else if (indexPath.row == 4) {
                cell.textLabel.text = NSLocalizedString(@"Blog", @"");
                cell.detailTextLabel.text = self.user.blog ? self.user.blog : @"-";
                if (self.user.blog) {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                }
            } else {
                cell.textLabel.text = NSLocalizedString(@"XXX", @"");
                cell.detailTextLabel.text = @"-";
            }
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionRepositories) {
        // display all repostories
        NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        
        GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHRepository *repository = [self.repositoriesArray objectAtIndex:indexPath.row-1];
        
        cell.titleLabel.text = repository.name;
        cell.descriptionLabel.text = repository.desctiptionRepo;
        
        if ([repository.private boolValue]) {
            cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
        }
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionWatchedRepositories) {
        // watched repositories
        if (indexPath.row <= [self.watchedRepositoriesArray count] ) {
            NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            
            GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            GHRepository *repository = [self.watchedRepositoriesArray objectAtIndex:indexPath.row-1];
            
            cell.titleLabel.text = [NSString stringWithFormat:@"%@/%@", repository.owner, repository.name];
            
            cell.descriptionLabel.text = repository.desctiptionRepo;
            
            if ([repository.private boolValue]) {
                cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
            }
            
            // Configure the cell...
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionPlan) {
        NSString *CellIdentifier = @"DetailsTableViewCell";
        
        UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Type", @"");
            cell.detailTextLabel.text = self.user.planName;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Private Repos", @"");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.user.planPrivateRepos];
        } else if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"Collaborators", @"");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.user.planCollaborators];
        } else if (indexPath.row == 4) {
            cell.textLabel.text = NSLocalizedString(@"Space", @"");
            cell.detailTextLabel.text = [NSString stringFormFileSize:self.user.planSpace];
        } else {
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = nil;
        }
        return cell;
    }
    
    return self.dummyCell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionUserData) {
        if (indexPath.row == 4 && self.user.blog) {
            NSURL *URL = [NSURL URLWithString:self.user.blog];
            GHWebViewViewController *web = [[[GHWebViewViewController alloc] initWithURL:URL] autorelease];
            [self.navigationController pushViewController:web animated:YES];
        }
    }
    if (indexPath.section == kUITableViewSectionRepositories) {
        GHRepository *repo = [self.repositoriesArray objectAtIndex:indexPath.row-1];
        
        GHSingleRepositoryViewController *viewController = [[[GHSingleRepositoryViewController alloc] initWithRepositoryString:[NSString stringWithFormat:@"%@/%@", repo.owner, repo.name] ] autorelease];
        viewController.delegate = self;
        self.lastIndexPathForSingleRepositoryViewController = indexPath;
        [self.navigationController pushViewController:viewController animated:YES];
        
    } else if (indexPath.section == kUITableViewSectionWatchedRepositories) {
        GHRepository *repo = [self.watchedRepositoriesArray objectAtIndex:indexPath.row-1];
        
        GHSingleRepositoryViewController *viewController = [[[GHSingleRepositoryViewController alloc] initWithRepositoryString:[NSString stringWithFormat:@"%@/%@", repo.owner, repo.name] ] autorelease];
        viewController.delegate = self;
        self.lastIndexPathForSingleRepositoryViewController = indexPath;
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionUserData && indexPath.row == 0) {
        return 71.0f;
    }
    if (indexPath.section == kUITableViewSectionRepositories) {
        if (indexPath.row == 0) {
            return 44.0f;
        }
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kUITableViewSectionWatchedRepositories) {
        if (indexPath.row == 0) {
            return 44.0f;
        }
        // watched repo
        return [self cachedHeightForRowAtIndexPath:indexPath];
    }
    return 44.0;
}

#pragma mark - GHCreateRepositoryViewControllerDelegate

- (void)createRepositoryViewController:(GHCreateRepositoryViewController *)createRepositoryViewController 
                   didCreateRepository:(GHRepository *)repository {
    [self dismissModalViewControllerAnimated:YES];
    [self downloadRepositories];
}

- (void)createRepositoryViewControllerDidCancel:(GHCreateRepositoryViewController *)createRepositoryViewController {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - GHSingleRepositoryViewControllerDelegate

- (void)singleRepositoryViewControllerDidDeleteRepository:(GHSingleRepositoryViewController *)singleRepositoryViewController {
    
    NSArray *oldArray = self.lastIndexPathForSingleRepositoryViewController.section == kUITableViewSectionRepositories ? self.repositoriesArray : self.watchedRepositoriesArray;
    NSUInteger index = self.lastIndexPathForSingleRepositoryViewController.row;
    
    NSMutableArray *array = [[oldArray mutableCopy] autorelease];
    [array removeObjectAtIndex:index];

    if (self.lastIndexPathForSingleRepositoryViewController.section == kUITableViewSectionRepositories) {
        self.repositoriesArray = array;
    } else {
        self.watchedRepositoriesArray = array;
    }
    
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.lastIndexPathForSingleRepositoryViewController] 
                          withRowAnimation:UITableViewRowAnimationTop];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end

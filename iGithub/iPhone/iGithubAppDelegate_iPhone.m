//
//  iGithubAppDelegate_iPhone.m
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "iGithubAppDelegate_iPhone.h"
#import "GithubAPI.h"
#import "UIColor+GithubUI.h"
#import "BlocksKit.h"

@implementation iGithubAppDelegate_iPhone

@synthesize tabBarController=_tabBarController, newsFeedViewController=_newsFeedViewController, profileViewController=_profileViewController, issuesOfUserViewController=_issuesOfUserViewController;

- (void)authenticationManagerDidAuthenticateUserCallback:(NSNotification *)notification {
    self.profileViewController.username = [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login;
    
    self.profileViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"My Profile", @"") 
                                                                           image:[UIImage imageNamed:@"145-persondot.png"] 
                                                                             tag:0];
}

- (void)setupAppearences
{
    id appearanceProxy = [UINavigationBar appearance];
    [appearanceProxy setTintColor:[UIColor defaultNavigationBarTintColor] ];
    
    appearanceProxy = [UIToolbar appearance];
    [appearanceProxy setTintColor:[UIColor defaultNavigationBarTintColor] ];
    
    appearanceProxy = [UISearchBar appearance];
    [appearanceProxy setTintColor:[UIColor defaultNavigationBarTintColor] ];
}

- (void)unknownPayloadEventTypeCallback:(NSNotification *)notification {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Unkown Event Type found"];
    [controller setMessageBody:[[notification userInfo] description] isHTML:NO]; 
    [self.tabBarController presentViewController:controller animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.tabBarController dismissModalViewControllerAnimated:YES];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // build userInterface here
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(authenticationManagerDidAuthenticateUserCallback:) 
                                                 name:GHAPIAuthenticationManagerDidChangeAuthenticatedUserNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(unknownPayloadEventTypeCallback:) 
                                                 name:@"GHUnknownPayloadEventType" 
                                               object:nil];
    
    NSMutableDictionary *dictionary = [self deserializeState];
    
//    dictionary = nil;
    if (dictionary) {
        self.tabBarController = [[UITabBarController alloc] init];
        self.window.rootViewController = self.tabBarController;
        
        NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:3];
        
        NSArray *viewControllers0 = [dictionary objectForKey:[NSNumber numberWithUnsignedInteger:0]];
        NSArray *viewControllers1 = [dictionary objectForKey:[NSNumber numberWithUnsignedInteger:1]];
        NSArray *viewControllers2 = [dictionary objectForKey:[NSNumber numberWithUnsignedInteger:2]];
        
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        [navigationController setViewControllers:viewControllers0 animated:NO];
        [viewControllers addObject:navigationController];
        
        navigationController = [[UINavigationController alloc] init];
        [navigationController setViewControllers:viewControllers1 animated:NO];
        [viewControllers addObject:navigationController];
        
        navigationController = [[UINavigationController alloc] init];
        [navigationController setViewControllers:viewControllers2 animated:NO];
        [viewControllers addObject:navigationController];
        
        self.tabBarController.viewControllers = viewControllers;
        self.tabBarController.selectedIndex = [[dictionary objectForKey:@"self.tabBarController.selectedIndex"] unsignedIntegerValue];
        
        self.newsFeedViewController = [viewControllers0 objectAtIndex:0];
        self.profileViewController = [viewControllers1 objectAtIndex:0];
        self.issuesOfUserViewController = [viewControllers2 objectAtIndex:0];
    } else {
        NSMutableArray *tabBarItems = [NSMutableArray array];
        
        self.tabBarController = [[UITabBarController alloc] init];
        self.window.rootViewController = self.tabBarController;
        
        self.newsFeedViewController = [[GHOwnersNeedsFeedViewController alloc] init];
        [tabBarItems addObject:[[UINavigationController alloc] initWithRootViewController:self.newsFeedViewController] ];
        
        self.profileViewController = [[GHAuthenticatedUserViewController alloc] init];
        [tabBarItems addObject:[[UINavigationController alloc] initWithRootViewController:self.profileViewController] ];
        
        self.issuesOfUserViewController = [[GHIssuesOfAuthenticatedUserViewController alloc] init];
        [tabBarItems addObject:[[UINavigationController alloc] initWithRootViewController:self.issuesOfUserViewController] ];
        
        self.tabBarController.viewControllers = tabBarItems;
    }
    
    self.profileViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"My Profile", @"") 
                                                                           image:[UIImage imageNamed:@"145-persondot.png"] 
                                                                             tag:0];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)showUserWithName:(NSString *)username
{
    GHUserViewController *viewController = [[GHUserViewController alloc] initWithUsername:username];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                         handler:^(id sender) {
                                                                             [self.tabBarController dismissModalViewControllerAnimated:YES];
                                                                         }];
    viewController.navigationItem.leftBarButtonItem = item;
    
    [self.tabBarController presentViewController:navigationController animated:YES completion:nil];
}

- (void)showRepositoryWithName:(NSString *)repositoryString
{
    GHRepositoryViewController *viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:repositoryString];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                         handler:^(id sender) {
                                                                             [self.tabBarController dismissModalViewControllerAnimated:YES];
                                                                         }];
    viewController.navigationItem.leftBarButtonItem = item;
    
    [self.tabBarController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Serialization

- (NSMutableDictionary *)serializedStateDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:5];
    [dictionary setObject:[NSNumber numberWithUnsignedInteger:self.tabBarController.selectedIndex] forKey:@"self.tabBarController.selectedIndex"];
    [self.tabBarController.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UINavigationController *navController = obj;
        [dictionary setObject:navController.viewControllers forKey:[NSNumber numberWithUnsignedInteger:idx]];
    }];
    
    return dictionary;
}

#pragma mark - memory management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

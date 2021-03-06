//
//  GHSearchViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 20.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GHViewController.h"

@interface GHSearchViewController : GHViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate> {
@private
    UISearchBar *_searchBar;
    UISearchDisplayController *_mySearchDisplayController;
    
    NSString *_searchString;
    
    BOOL _isSearchBarActive;
    BOOL _canTrackSearchBarState;
}

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, copy) NSString *searchString;

@end

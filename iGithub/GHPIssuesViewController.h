//
//  GHPIssuesViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 04.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@interface GHPIssuesViewController : GHTableViewController {
@private
    NSMutableArray *_issues;
    
    NSString *_repository;
}

@property (nonatomic, retain) NSMutableArray *issues;

- (void)cacheIssuesHeight;

@property (nonatomic, copy) NSString *repository;

- (id)initWithRepository:(NSString *)repository;


@end

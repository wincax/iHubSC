//
//  MyTableViewCell.h
//  Installous
//
//  Created by Oliver Letterer on 25.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GHIssueFeedItemTableViewCell : UITableViewCell {
@private
    IBOutlet UIView *_myContentView;
    IBOutlet UIImageView *_gravatarImageView;
}

@property (nonatomic, retain) UIImageView *gravatarImageView;

@end

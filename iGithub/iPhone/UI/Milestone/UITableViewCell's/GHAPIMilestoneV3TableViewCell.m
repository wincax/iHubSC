//
//  GHAPIMilestoneV3TableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 30.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIMilestoneV3TableViewCell.h"

CGFloat const kGHAPIMilestoneV3TableViewCellHeight = 100.0f;



@implementation GHAPIMilestoneV3TableViewCell
@synthesize progressView=_progressView;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        _progressView = [[GHGlossProgressView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_progressView];
    }
    return self;
}

#pragma mark - super implementation

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(10.0f, 5.0f, CGRectGetWidth(self.contentView.bounds) - 20.0f, 30.0f);
    [self.textLabel sizeToFit];
    
    CGFloat offsetY = CGRectGetHeight(self.textLabel.frame) + self.textLabel.frame.origin.y + 5.0f;
    self.detailTextLabel.frame = CGRectMake(10.0f, offsetY, CGRectGetWidth(self.contentView.bounds) - 20.0f, 30.0f);
    [self.detailTextLabel sizeToFit];
    
    offsetY = CGRectGetHeight(self.detailTextLabel.frame) + self.detailTextLabel.frame.origin.y + 5.0f;
    self.progressView.frame = CGRectMake(10.0f, offsetY, CGRectGetWidth(self.contentView.bounds) - 20.0f, 30.0f);
    
//    CGRect frame = self.detailTextLabel.frame;
//    frame.size.width = self.contentView.bounds.size.width - frame.origin.x - 10.0f;
//    frame.size.height = self.progressView.frame.size.height;
//    self.progressView.frame = frame;
//    
//    CGPoint center = self.progressView.center;
//    center.y = self.detailTextLabel.center.y - 5.0;
//    self.progressView.center = center;
//    
//    center = self.textLabel.center;
//    center.y -= 5.0f;
//    self.textLabel.center = center;
//    
//    center = self.detailTextLabel.center;
//    center.y += 12.0f;
//    self.detailTextLabel.center = center;
}

@end

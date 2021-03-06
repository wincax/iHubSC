//
//  GHViewCloudFileViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GithubAPI.h"
#import "UIViewController+GHErrorHandling.h"
#import "DDProgressView.h"
#import "GHViewController.h"

@interface GHViewCloudFileViewController : GHViewController <UIScrollViewDelegate, ASIProgressDelegate, UIWebViewDelegate> {
@private
    NSString *_repository;
    NSString *_tree;
    NSString *_filename;
    NSString *_relativeURL;
    NSString *_branch;
    
    GHFileMetaData *_metadata;
    NSString *_contentString;
    NSString *_markdownString;
    UIImage *_contentImage;
    BOOL _isMimeTypeUnkonw;
    
    BOOL _showFileFromGitHub;
    
    ASIHTTPRequest *_request;
    
    UIScrollView *_scrollView;
    CAGradientLayer *_backgroundGradientLayer;
    UILabel *_loadingLabel;
    UIActivityIndicatorView *_activityIndicatorView;
    DDProgressView *_progressView;
    UIImageView *_imageView;
}

@property (nonatomic, copy) NSString *repository;
@property (nonatomic, copy) NSString *tree;
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSString *relativeURL;
@property (nonatomic, copy) NSString *branch;

@property (nonatomic, retain) GHFileMetaData *metadata;
@property (nonatomic, copy) NSString *contentString;
@property (nonatomic, copy) NSString *markdownString;
@property (nonatomic, retain) UIImage *contentImage;

@property (nonatomic, retain) ASIHTTPRequest *request;

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) CAGradientLayer *backgroundGradientLayer;
@property (nonatomic, retain) UILabel *loadingLabel;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) DDProgressView *progressView;
@property (nonatomic, retain) UIImageView *imageView;

- (id)initWithRepository:(NSString *)repository tree:(NSString *)tree filename:(NSString *)filename relativeURL:(NSString *)relativeURL;
- (id)initWithFile:(NSString *)filename contentsOfFile:(NSString *)content;
- (id)initWithRepository:(NSString *)repository filename:(NSString *)filename branch:(NSString *)branch relativeURL:(NSString *)relativeURL;

- (void)updateViewToShowPlainTextFile;
- (void)updateViewToShowMarkdownFile;
- (void)updateViewForImageDownload;
- (void)updateViewForImageContent;
- (void)updateViewForUnkownMimeType;

- (NSString *)HTMLPageStringFromFileContent:(NSString *)fileContent;

@end

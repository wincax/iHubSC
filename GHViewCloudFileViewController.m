//
//  GHViewCloudFileViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHViewCloudFileViewController.h"
#import "WAHTMLMarkdownFormatter.h"
#import "GHLinearGradientBackgroundView.h"

@implementation GHViewCloudFileViewController

@synthesize repository=_repository, tree=_tree, filename=_filename, relativeURL=_relativeURL;
@synthesize metadata=_metadata, contentString=_contentString, markdownString=_markdownString, contentImage=_contentImage;
@synthesize request=_request;
@synthesize scrollView=_scrollView, backgroundGradientLayer=_backgroundGradientLayer, loadingLabel=_loadingLabel, activityIndicatorView=_activityIndicatorView, progressView=_progressView, imageView=_imageView;

#pragma mark - Initialization

- (void)setMetadata:(GHFileMetaData *)metadata {
    if (metadata != _metadata) {
        [_metadata release];
        _metadata = [metadata retain];
        
        if ([_metadata.mimeType rangeOfString:@"image"].location != NSNotFound) {
            [self updateViewForImageDownload];
            self.request = [self.metadata requestForContent];
            self.request.delegate = self;
            [self.request setCompletionBlock:^(void) {
                self.contentImage = [[[UIImage alloc] initWithData:[self.request responseData] ] autorelease];
                [self.request clearDelegatesAndCancel];
                self.request = nil;
                [self updateViewForImageContent];
            }];
            self.request.downloadProgressDelegate = self.progressView;
            
            [self.request startAsynchronous];
        } else {
            [_metadata contentOfFileWithCompletionHandler:^(NSData *data, NSError *error) {
                if (error) {
                    [self handleError:error];
                } else {
                    NSString *fileString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                    
                    if (fileString) {
                        if ([self.filename hasSuffix:@".md"] || [self.filename hasSuffix:@".markdown"] || [self.filename hasSuffix:@".mdown"]) {
                            self.markdownString = fileString.HTMLMarkdownFormattedString;
                            [self updateViewToShowMarkdownFile];
                        } else {
                            self.contentString = [self HTMLPageStringFromFileContent:fileString];
                            [self updateViewToShowPlainTextFile];
                        }
                    } else {
                        _isMimeTypeUnkonw = YES;
                        [self updateViewForUnkownMimeType];
                    }
                }
            }];
        }
    }
}

- (id)initWithRepository:(NSString *)repository tree:(NSString *)tree filename:(NSString *)filename relativeURL:(NSString *)relativeURL {
    if ((self = [super init])) {
        self.repository = repository;
        self.tree = tree;
        self.filename = filename;
        self.relativeURL = relativeURL;
        self.title = self.filename;
        [GHFileMetaData metaDataOfFile:self.filename 
                         atRelativeURL:self.relativeURL 
                          onRepository:self.repository 
                                  tree:self.tree 
                     completionHandler:^(GHFileMetaData *metaData, NSError *error) {
                         if (error) {
                             [self handleError:error];
                         } else {
                             self.metadata = metaData;
                         }
                     }];
    }
    return self;
}

- (id)initWithFile:(NSString *)filename contentsOfFile:(NSString *)content {
    if (self == [super init]) {
        self.filename = filename;
        self.contentString = content;
        self.title = filename;
    }
    return self;
}

#pragma mark - HTML parsing

- (NSString *)HTMLPageStringFromFileContent:(NSString *)fileContent {
    NSMutableDictionary *brushesForFileExtensionsDictionary = [NSMutableDictionary dictionary];
    [brushesForFileExtensionsDictionary setObject:@"javascript" forKey:@".js"];
    [brushesForFileExtensionsDictionary setObject:@"ruby" forKey:@".rb"];
    [brushesForFileExtensionsDictionary setObject:@"python" forKey:@".py"];
    
    [brushesForFileExtensionsDictionary setObject:@"c" forKey:@".h"];
    [brushesForFileExtensionsDictionary setObject:@"c" forKey:@".mm"];
    [brushesForFileExtensionsDictionary setObject:@"c" forKey:@".m"];
    [brushesForFileExtensionsDictionary setObject:@"c" forKey:@".c"];
    [brushesForFileExtensionsDictionary setObject:@"c" forKey:@".cpp"];
    [brushesForFileExtensionsDictionary setObject:@"c" forKey:@".c++"];
    [brushesForFileExtensionsDictionary setObject:@"c" forKey:@".hpp"];
    [brushesForFileExtensionsDictionary setObject:@"c" forKey:@".h++"];
    
    [brushesForFileExtensionsDictionary setObject:@"php" forKey:@".php"];
    [brushesForFileExtensionsDictionary setObject:@"bash" forKey:@".sh"];
    [brushesForFileExtensionsDictionary setObject:@"perl" forKey:@".pl"];
    [brushesForFileExtensionsDictionary setObject:@"java" forKey:@".java"];
    
    
    NSMutableString *HTMLString = [NSMutableString stringWithString:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\
                                   <html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\
                                   <head>\
                                   <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\
                                   <script type=\"text/javascript\" src=\"scripts/shCore.js\"></script>\
                                   <script type=\"text/javascript\" src=\"scripts/shBrushJScript.js\"></script>\
                                   <script type=\"text/javascript\" src=\"scripts/shBrushRuby.js\"></script>\
                                   <script type=\"text/javascript\" src=\"scripts/shBrushPython.js\"></script>\
                                   <script type=\"text/javascript\" src=\"scripts/shBrushPhp.js\"></script>\
                                   <script type=\"text/javascript\" src=\"scripts/shBrushBash.js\"></script>\
                                   <script type=\"text/javascript\" src=\"scripts/shBrushPerl.js\"></script>\
                                   <script type=\"text/javascript\" src=\"scripts/shBrushJava.js\"></script>\
                                   \
                                   <script type=\"text/javascript\" src=\"scripts/shBrushCpp.js\"></script>\
                                   <link type=\"text/css\" rel=\"stylesheet\" href=\"styles/shCoreDefault.css\"/>\
                                   <script type=\"text/javascript\">SyntaxHighlighter.all();</script>\
                                   </head>\
                                   \
                                   <body style=\"background: white; font-family: Helvetica\">"];
//    [HTMLString appendString:@"<body style=\"background: -webkit-gradient(linear, left top, left bottom, from(#f0f0f0), to(#c0c0c0));\"><pre>"];
    
    NSMutableString *brushType = [NSMutableString stringWithString:@""];
    
    [brushesForFileExtensionsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *theKey = key;
        NSString *theObject = obj;
        
        if ([self.filename rangeOfString:theKey].location != NSNotFound) {
            *stop = YES;
            [brushType appendString:theObject];
        }
    }];
    
    [HTMLString appendFormat:@"<pre class=\"brush: %@;\" width=\"320px\">", brushType];
    
    NSMutableString *result = [NSMutableString stringWithString:fileContent];
    
    [result replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"'" withString:@"&#39;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    
    [HTMLString appendString:result];
    
    [HTMLString appendString:@"</pre></body>"];
    
    return HTMLString;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repository release];
    [_tree release];
    [_filename release];
    [_metadata release];
    [_relativeURL release];
    [_scrollView release];
    [_backgroundGradientLayer release];
    [_loadingLabel release];
    [_activityIndicatorView release];
    [_progressView release];
    [_imageView release];
    [_markdownString release];
    [_contentString release];
    
    [_request clearDelegatesAndCancel];
    [_request release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    self.view = [[[GHLinearGradientBackgroundView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f)] autorelease];
    
    self.scrollView = [[[UIScrollView alloc] initWithFrame:self.view.bounds] autorelease];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.showsHorizontalScrollIndicator = YES;
    self.scrollView.contentInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    self.loadingLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 170.0, 320.0, 20.0)] autorelease];
    self.loadingLabel.backgroundColor = [UIColor clearColor];
    self.loadingLabel.textColor = [UIColor blackColor];
    self.loadingLabel.textAlignment = UITextAlignmentCenter;
    self.loadingLabel.text = NSLocalizedString(@"Downloading ...", @"");
    self.loadingLabel.font = [UIFont systemFontOfSize:17.0];
    [self.loadingLabel sizeToFit];
    self.loadingLabel.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2.0f, CGRectGetHeight(self.view.bounds)/2.0f);
    self.loadingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.loadingLabel];
    
    self.activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.activityIndicatorView.center = CGPointMake(self.loadingLabel.frame.origin.x - 10.0f, CGRectGetHeight(self.view.bounds)/2.0f);
    self.activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.activityIndicatorView startAnimating];
    [self.view addSubview:self.activityIndicatorView];
    
    if (self.contentString) {
        [self updateViewToShowPlainTextFile];
    } else if (self.markdownString) {
        [self updateViewToShowMarkdownFile];
    } else if (self.contentImage) {
        [self updateViewForImageContent];
    } else if (self.request) {
        [self updateViewForImageDownload];
    } else if (_isMimeTypeUnkonw) {
        [self updateViewForUnkownMimeType];
    }
}

- (void)updateViewForUnkownMimeType {
    if (![self isViewLoaded] || !_isMimeTypeUnkonw) {
        return;
    }
    
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
    
    self.loadingLabel.text = NSLocalizedString(@"Unable to display MIME-Type", @"");
    [self.loadingLabel sizeToFit];
    self.loadingLabel.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2.0f, CGRectGetHeight(self.view.bounds)/2.0f);
}

- (void)updateViewToShowPlainTextFile {
    if (![self isViewLoaded]) {
        return;
    }
    
    DLog(@"wow");
    
    [self.loadingLabel removeFromSuperview];
    self.loadingLabel = nil;
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
    
    CGRect frame = self.view.bounds;
    
    UIWebView *webView = [[[UIWebView alloc] initWithFrame:frame] autorelease];
    [webView loadHTMLString:self.contentString baseURL:[[NSBundle mainBundle] URLForResource:@"" withExtension:nil]];
    webView.scalesPageToFit = YES;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.scrollView.backgroundColor = [UIColor clearColor];
    webView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:webView];
}

- (void)updateViewToShowMarkdownFile {
    if (![self isViewLoaded]) {
        return;
    }
    
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
    [self.loadingLabel removeFromSuperview];
    self.loadingLabel = nil;
    
    CGRect frame = CGRectMake(0.0, 0.0, 320.0, 367.0f);
    
    UIWebView *webView = [[[UIWebView alloc] initWithFrame:frame] autorelease];
    [webView loadHTMLString:self.markdownString baseURL:nil];
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];
}

- (void)updateViewForImageDownload {
    if (![self isViewLoaded]) {
        return;
    }
    
    [self.backgroundGradientLayer removeFromSuperlayer];
    self.backgroundGradientLayer = nil;
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
    [self.loadingLabel removeFromSuperview];
    self.loadingLabel = nil;
    
    self.progressView = [[[DDProgressView alloc] initWithFrame:CGRectMake(20.0, CGRectGetHeight(self.view.bounds)-10.0f, CGRectGetWidth(self.view.bounds) - 40.0f, 20.0f)] autorelease];
    self.progressView.alpha = 0.0;
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.progressView];
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.view.backgroundColor = [UIColor blackColor];
        self.progressView.alpha = 1.0;
    }];
}

- (void)updateViewForImageContent {
    if (![self isViewLoaded]) {
        return;
    }
    self.view.backgroundColor = [UIColor blackColor];
    [self.progressView removeFromSuperview];
    self.progressView = nil;
    
    [self.backgroundGradientLayer removeFromSuperlayer];
    self.backgroundGradientLayer = nil;
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
    [self.loadingLabel removeFromSuperview];
    self.loadingLabel = nil;
    
    self.imageView = [[[UIImageView alloc] initWithImage:self.contentImage] autorelease];
    [self.scrollView addSubview:self.imageView];
    [self.imageView sizeToFit];
    
    self.scrollView.contentSize = self.imageView.frame.size;
    
    if (self.scrollView.contentSize.width < self.scrollView.bounds.size.width) {
        // move image into center
        CGPoint oldCenter = self.imageView.center;
        oldCenter.x = self.scrollView.bounds.size.width / 2.0f;
        self.imageView.center = oldCenter;
    }
    
    if (self.scrollView.contentSize.height < self.scrollView.bounds.size.height) {
        CGPoint oldCenter = self.imageView.center;
        oldCenter.y = self.scrollView.bounds.size.height / 2.0f;
        self.imageView.center = oldCenter;
    }
    
    self.scrollView.minimumZoomScale = self.scrollView.bounds.size.width / self.imageView.frame.size.width;
    
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [_scrollView release];
    _scrollView = nil;
    [_backgroundGradientLayer release];
    _backgroundGradientLayer = nil;
    [_loadingLabel release];
    _loadingLabel = nil;
    [_activityIndicatorView release];
    _activityIndicatorView = nil;
    [_progressView release];
    _progressView = nil;
    [_imageView release];
    _imageView = nil;
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
@end

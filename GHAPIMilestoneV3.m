//
//  GHAPIMilestoneV3.m
//  iGithub
//
//  Created by Oliver Letterer on 30.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIMilestoneV3.h"
#import "GithubAPI.h"

@implementation GHAPIMilestoneV3

@synthesize closedIssues=_closedIssues, createdAt=_createdAt, creator=_creator, milestoneDescription=_milestoneDescription, dueOn=_dueOn, number=_number, openIssues=_openIssues, state=_state, title=_title, URL=_URL;

- (NSString *)dueFormattedString {
    if (!self.dueOn) {
        return NSLocalizedString(@"No due date", @"");
    }
    
    NSDate *pastDate = self.dueOn.dateFromGithubAPIDateString;
    
    NSString *timeString = pastDate.prettyTimeIntervalSinceNow;
    
    if (self.dueInTime) {
        return [NSString stringWithFormat:NSLocalizedString(@"Due in %@", @""), timeString];
    }
    
    return [NSString stringWithFormat:NSLocalizedString(@"Past due by %@", @""), timeString];
}

- (BOOL)dueInTime {
    NSDate *pastDate = self.dueOn.dateFromGithubAPIDateString;
    
    return [pastDate timeIntervalSinceNow] > 0 || !self.dueOn;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay {
    if ((self = [super init])) {
        // Initialization code
        self.closedIssues = [rawDictionay objectForKeyOrNilOnNullObject:@"closed_issues"];
        self.createdAt = [rawDictionay objectForKeyOrNilOnNullObject:@"created_at"];
        self.milestoneDescription = [rawDictionay objectForKeyOrNilOnNullObject:@"description"];
        self.dueOn = [rawDictionay objectForKeyOrNilOnNullObject:@"due_on"];
        self.number = [rawDictionay objectForKeyOrNilOnNullObject:@"number"];
        self.openIssues = [rawDictionay objectForKeyOrNilOnNullObject:@"open_issues"];
        self.state = [rawDictionay objectForKeyOrNilOnNullObject:@"state"];
        self.title = [rawDictionay objectForKeyOrNilOnNullObject:@"title"];
        self.URL = [rawDictionay objectForKeyOrNilOnNullObject:@"url"];
        self.creator = [[[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionay objectForKeyOrNilOnNullObject:@"creator"] ] autorelease];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_closedIssues release];
    [_createdAt release];
    [_creator release];
    [_milestoneDescription release];
    [_dueOn release];
    [_number release];
    [_openIssues release];
    [_state release];
    [_title release];
    [_URL release];
    
    [super dealloc];
}

#pragma mark - downloading

+ (void)milestoneOnRepository:(NSString *)repository number:(NSNumber *)number 
            completionHandler:(void(^)(GHAPIMilestoneV3 *milestone, NSError *error))handler {
    
    // v3: GET /repos/:user/:repo/milestones/:id
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/milestones/%@",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                       number]];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL setupHandler:nil completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
        if (error) {
            handler(nil, error);
        } else {
            handler([[[GHAPIMilestoneV3 alloc] initWithRawDictionary:object] autorelease], nil);
        }
    }];
}

@end
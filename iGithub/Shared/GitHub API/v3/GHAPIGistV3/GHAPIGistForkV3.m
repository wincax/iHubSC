//
//  GHAPIGistForkV3.m
//  iGithub
//
//  Created by Oliver Letterer on 05.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIGistForkV3.h"
#import "GithubAPI.h"

@implementation GHAPIGistForkV3

@synthesize user=_user, URL=_URL, createdAt=_createdAt;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.user = [[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"user"] ];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_user forKey:@"user"];
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _user = [decoder decodeObjectForKey:@"user"];
        _URL = [decoder decodeObjectForKey:@"uRL"];
        _createdAt = [decoder decodeObjectForKey:@"createdAt"];
    }
    return self;
}

@end

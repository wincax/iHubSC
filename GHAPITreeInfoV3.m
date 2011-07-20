//
//  GHAPITreeInfoV3.m
//  iGithub
//
//  Created by Oliver Letterer on 23.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPITreeInfoV3.h"
#import "GithubAPI.h"

@implementation GHAPITreeInfoV3

@synthesize URL = _URL, SHA = _SHA;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.SHA = [rawDictionary objectForKeyOrNilOnNullObject:@"sha"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_URL release];
    [_SHA release];
    
    [super dealloc];
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_SHA forKey:@"sHA"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _URL = [[decoder decodeObjectForKey:@"uRL"] retain];
        _SHA = [[decoder decodeObjectForKey:@"sHA"] retain];
    }
    return self;
}

@end

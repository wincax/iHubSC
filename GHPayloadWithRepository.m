//
//  GHPayloadWithRepository.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPayloadWithRepository.h"
#import "GithubAPI.h"

@implementation GHPayloadWithRepository

@synthesize repository=_repository;

- (NSString *)repo {
    return self.repository.fullName;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.repository = [[[GHRepository alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"repository"]] autorelease];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repository release];
    [super dealloc];
}

@end

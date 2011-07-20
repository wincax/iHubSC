//
//  GHAPIRepositoryBranchV3.m
//  iGithub
//
//  Created by Oliver Letterer on 11.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIRepositoryBranchV3.h"
#import "GithubAPI.h"

@implementation GHAPIRepositoryBranchV3

@synthesize name = _name, ID = _ID;

#pragma mark - Initialization

- (id)initWithName:(NSString *)name ID:(NSString *)ID {
    if ((self = [super init])) {
        // Initialization code
        self.name = name;
        self.ID = ID;
    }
    return self;
}

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        self.name = [rawDictionary objectForKeyOrNilOnNullObject:@"name"];
        self.ID = [rawDictionary objectForKeyOrNilOnNullObject:@"sha"];
        
        if (!self.ID) {
            NSDictionary *commitDictionary = [rawDictionary objectForKeyOrNilOnNullObject:@"commit"];
            self.ID = [commitDictionary objectForKeyOrNilOnNullObject:@"sha"];
        }
    }
    return self;
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_ID forKey:@"iD"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _name = [[decoder decodeObjectForKey:@"name"] retain];
        _ID = [[decoder decodeObjectForKey:@"iD"] retain];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_name release];
    [_ID release];
    
    [super dealloc];
}

@end

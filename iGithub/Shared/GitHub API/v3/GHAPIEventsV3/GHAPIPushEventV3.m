//
//  GHAPIPushEventEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPIPushEventV3
@synthesize head=_head, ref=_ref, numberOfCommits=_numberOfCommits, commits=_commits;

#pragma mark - setters and getters

- (NSString *)branch
{
    return [_ref componentsSeparatedByString:@"/"].lastObject;
}

- (NSString *)previewString 
{
    NSMutableString *previewString = [NSMutableString string];
    
    [_commits enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPICommitV3 *commit = obj;
        if (idx == 1) {
            [previewString appendFormat:@"\n- %@", commit.message];
        } else if (idx == 2) {
            NSUInteger remainingCommits = _commits.count - idx;
            if (remainingCommits == 1) {
                [previewString appendFormat:@"\n%d more commit...", remainingCommits];
            } else {
                [previewString appendFormat:@"\n%d more commits...", remainingCommits];
            }
            *stop = YES;
        } else {
            [previewString appendFormat:@"- %@", commit.message];
        }
    }];
    
    return previewString;
}

#pragma mark - Initialization

- (id)initWithRawPayloadDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawPayloadDictionary:rawDictionary]) {
        // Initialization code
        _head = [rawDictionary objectForKeyOrNilOnNullObject:@"head"];
        _ref = [rawDictionary objectForKeyOrNilOnNullObject:@"ref"];
        _numberOfCommits = [rawDictionary objectForKeyOrNilOnNullObject:@"size"];
        
        NSArray *rawArray = [rawDictionary objectForKeyOrNilOnNullObject:@"commits"];
        GHAPIObjectExpectedClass(&rawArray, NSArray.class);
        
        NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
        [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [finalArray addObject:[[GHAPICommitV3 alloc] initWithRawDictionary:obj] ];
        }];
        
        _commits = finalArray;
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_head forKey:@"head"];
    [encoder encodeObject:_ref forKey:@"ref"];
    [encoder encodeObject:_numberOfCommits forKey:@"numberOfCommits"];
    [encoder encodeObject:_commits forKey:@"commits"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super initWithCoder:decoder])) {
        _head = [decoder decodeObjectForKey:@"head"];
        _ref = [decoder decodeObjectForKey:@"ref"];
        _numberOfCommits = [decoder decodeObjectForKey:@"numberOfCommits"];
        _commits = [decoder decodeObjectForKey:@"commits"];
    }
    return self;
}

@end

//
//  GHAPIMilestoneV3.h
//  iGithub
//
//  Created by Oliver Letterer on 30.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHAPIConnectionHandlersV3.h"

@class GHAPIUserV3;

@interface GHAPIMilestoneV3 : NSObject <NSCoding> {
@private
    NSNumber *_closedIssues;
    NSString *_createdAt;
    GHAPIUserV3 *_creator;
    NSString *_milestoneDescription;
    NSString *_dueOn;
    NSNumber *_number;
    NSNumber *_openIssues;
    NSString *_state;
    NSString *_title;
    NSString *_URL;
}

@property (nonatomic, copy) NSNumber *closedIssues;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, retain) GHAPIUserV3 *creator;
@property (nonatomic, copy) NSString *milestoneDescription;
@property (nonatomic, copy) NSString *dueOn;
@property (nonatomic, copy) NSNumber *number;
@property (nonatomic, copy) NSNumber *openIssues;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *URL;

@property (nonatomic, readonly) NSString *dueFormattedString;
@property (nonatomic, readonly) BOOL dueInTime;

@property (nonatomic, readonly) CGFloat progress;

- (BOOL)isEqualToMilestone:(GHAPIMilestoneV3 *)milestone;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

+ (void)milestoneOnRepository:(NSString *)repository number:(NSNumber *)number 
            completionHandler:(void(^)(GHAPIMilestoneV3 *milestone, NSError *error))handler;

+ (void)createMilestoneOnRepository:(NSString *)repository title:(NSString *)title description:(NSString *)description dueOn:(NSDate *)dueOn completionHandler:(void(^)(GHAPIMilestoneV3 *milestone, NSError *error))handler;

+ (void)updateMilestoneOnRepository:(NSString *)repository withID:(NSNumber *)ID title:(NSString *)title description:(NSString *)description dueOn:(NSDate *)dueOn completionHandler:(void(^)(GHAPIMilestoneV3 *milestone, NSError *error))handler;

+ (void)deleteMilstoneOnRepository:(NSString *)repository withID:(NSNumber *)ID completionHandler:(GHAPIErrorHandler)handler;

@end

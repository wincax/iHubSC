//
//  iGithubAppDelegate.h
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#warning better organization support
#warning add a calendar to edit due dates
#warning images for users on iPhone
#warning update milestone and all other related issue data
#warning update create issue view on iphone
#warning what happens, if password changes?
#warning make README directly showable

@interface iGithubAppDelegate : NSObject <UIApplicationDelegate> {
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSMutableDictionary *serializedStateDictionary;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)setupAppearences;

- (void)nowSerializeState;
- (BOOL)serializeStateInDictionary:(NSMutableDictionary *)dictionary;
- (NSMutableDictionary *)deserializeState;

@end

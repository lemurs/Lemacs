//
//  LEAppDelegate.h
//  Lemacs
//
//  Created by Mike Lee on 7/18/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@class UAGithubEngine;

@interface LEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UAGithubEngine *GitHub;
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSURL *applicationDocumentsDirectory;

- (IBAction)removeContext;
- (IBAction)saveContext;
- (IBAction)showLogin;
- (IBAction)showLoginIfNeeded;

@end

extern NSString * const kLEGitHubServiceName;
extern NSString * const kLEGitHubPasswordKey;
extern NSString * const kLEGitHubUsernameKey;

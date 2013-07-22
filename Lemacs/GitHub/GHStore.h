//
//  GHStore.h
//  Lemacs
//
//  Created by Mike Lee on 7/21/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@class GHIssue, GHUser, UAGithubEngine;

@interface GHStore : NSObject

+ (instancetype)sharedStore;

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) UAGithubEngine *GitHub;

- (IBAction)save;
- (IBAction)showLoginIfNeeded;

- (void)logInWithUsername:(NSString *)username password:(NSString *)password;

// Issues
- (void)reloadIssues;
- (void)loadCommentsForIssue:(GHIssue *)issue;
- (void)loadUser:(GHUser *)user;

@end

extern const NSTimeInterval kGHStoreUpdateLimit;

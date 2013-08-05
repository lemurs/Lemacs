//
//  GHStore.h
//  Lemacs
//
//  Created by Mike Lee on 7/21/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@class GHComment, GHIssue, GHUser, UAGithubEngine;

@interface GHStore : NSObject

+ (instancetype)sharedStore;

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) UAGithubEngine *GitHub;

- (IBAction)refreshIssues;
- (IBAction)save;
- (IBAction)showLoginIfNeeded;
- (IBAction)sync;

- (void)logInWithUsername:(NSString *)username password:(NSString *)password;

// Issues
- (void)loadIssues:(BOOL)freshStart;
- (void)loadCommentsForIssue:(GHIssue *)issue;
- (void)loadUser:(GHUser *)user;

// Saving
- (void)deleteComment:(GHComment *)comment;
- (void)deleteIssue:(GHIssue *)issue;
- (void)saveComment:(GHComment *)comment;
- (void)saveIssue:(GHIssue *)issue;

@end

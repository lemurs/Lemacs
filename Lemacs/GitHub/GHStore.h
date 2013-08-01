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
- (void)addIssue:(GHIssue *)issue;
- (void)deleteIssue:(GHIssue *)issue;
- (void)loadIssues:(BOOL)freshStart;
- (void)loadCommentsForIssue:(GHIssue *)issue;
- (void)loadUser:(GHUser *)user;

// Comments
- (void)addComment:(GHComment *)comment toIssue:(GHIssue *)issue;
- (void)deleteComment:(GHComment *)comment;

@end

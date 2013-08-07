//
//  GHStore.m
//  Lemacs
//
//  Created by Mike Lee on 7/21/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHStore.h"

#import "GHComment.h"
#import "GHIssue.h"
#import "GHUser.h"
#import "NSError+LEPresenting.h"

#import <UAGithubEngine/UAGithubEngine.h>
#import <UICKeyChainStore/UICKeyChainStore.h>

@interface GHStore ()

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, strong, readonly) NSURL *applicationDocumentsDirectory;
@property (nonatomic, strong, readonly) NSString *repositoryPath;

- (IBAction)removeContext;
- (IBAction)showLogin;

@end


void (^handleError)(NSError *) = ^(NSError *error){
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if ([error.domain isEqualToString:@"HTTP"]) {
        switch (error.code) {
            case 403: // Happens when your password is wrong
                error = [NSError errorWithDomain:error.domain code:error.code userInfo:@{NSLocalizedDescriptionKey :  NSLocalizedString(@"GitHub refuses to speak to you. Check your login credentials.", @"Incorrect password description")}];
                [[GHStore sharedStore] showLogin];
                return;

            case 405: // FIXME: Happens when trying to save when GitHub is down. Changes should be saved locally and synced next time.
            case 502:
            case 503:
                [[NSNotificationCenter defaultCenter] postNotificationName:kGitHubDownStatusNotification object:error userInfo:error.userInfo];
                return NSLog(@"GitHub is down. Show a confused Octocat.");
        }
    }

    if ([error.domain isEqualToString:@"NSURLErrorDomain"]) {
        switch (error.code) {
            case -1001:
                [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkSlowStatusNotification object:error userInfo:error.userInfo];
                return NSLog(@"Network is slow. Show an old Octocat.");
        }
    }

    [error present];
};


@implementation GHStore

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSString *username = [(UITextField*)[alertView textFieldAtIndex:0] text];
    NSString *password = [(UITextField*)[alertView textFieldAtIndex:1] text];

    [UICKeyChainStore setString:username forKey:kLEGitHubUsernameKey service:kLEGitHubServiceName];
    [UICKeyChainStore setString:password forKey:kLEGitHubPasswordKey service:kLEGitHubServiceName];

    self.GitHub = [[UAGithubEngine alloc] initWithUsername:username password:password withReachability:YES];
    [self loadIssues:YES];
}



#pragma mark - API

NSString * const kLEGitHubServiceName = @"com.github";
NSString * const kLEGitHubPasswordKey = @"password";
NSString * const kLEGitHubUsernameKey = @"username";

+ (instancetype)sharedStore;
{
    static GHStore *sharedStore;
    return sharedStore ? : (sharedStore = [[self alloc] init]);
}

- (void)logInWithUsername:(NSString *)username password:(NSString *)password;
{
    self.GitHub = [[UAGithubEngine alloc] initWithUsername:username password:password withReachability:YES];
}



#pragma mark Properties

@synthesize managedObjectContext = _managedObjectContext, managedObjectModel = _managedObjectModel, persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)repositoryPath;
{
    return @"lemurs/Lemacs";
}


#pragma mark Core Data

- (NSManagedObjectContext *)managedObjectContext;
{// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
    if (_managedObjectContext)
        return _managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
    }

    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel;
{// If the model doesn't already exist, it is created from the application's model.
    if (_managedObjectModel)
        return _managedObjectModel;

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Lemacs" withExtension:@"momd"]; // FIXME: Factor out inline constants
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
{// If the coordinator doesn't already exist, it is created and the application's store added to it.
    if (_persistentStoreCoordinator != nil)
        return _persistentStoreCoordinator;

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Lemacs.sqlite"]; // FIXME: Factor out inline constants

    NSError *storeLoadingError = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&storeLoadingError]) {
        /*
         TODO: Replace this implementation with code to handle the error appropriately.

         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.


         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]

         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}

         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.

         */
        [storeLoadingError present];
        [self removeContext];
        abort();
    }

    return _persistentStoreCoordinator;
}


#pragma mark Actions

- (IBAction)refreshIssues;
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSDate *lastUpdated = NonNil([context.userInfo valueForKey:kGHUpdatedDatePropertyName], [NSDate distantPast]);
    NSTimeInterval staleness = -[lastUpdated timeIntervalSinceNow];
    if (staleness > kGHStoreUpdateLimit)
        [self loadIssues:NO];
}

- (IBAction)removeContext;
{
    NSURL *storeURL = [self.applicationDocumentsDirectory URLByAppendingPathComponent:@"Lemacs.sqlite"]; // FIXME: Factor out inline constants

    NSError *storeDeletingError = nil;
    if (![[NSFileManager defaultManager] removeItemAtURL:storeURL error:&storeDeletingError])
        [storeDeletingError present];
}

- (IBAction)save;
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (!managedObjectContext || !managedObjectContext.hasChanges)
        return; // Abort

    NSError *contextSavingError;
    if ([managedObjectContext save:&contextSavingError])
        return; // Success

    [contextSavingError present];

    // TODO: Make this do what it's supposed to.

    abort();
}

- (IBAction)showLogin;
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Account", @"GitHub login Title") message:NSLocalizedString(@"Sign in to GitHub", @"GitHub login message") delegate:self cancelButtonTitle:NSLocalizedString(@"Not now", @"GitHub login cancel button title") otherButtonTitles:NSLocalizedString(@"Sign in", @"GitHub login OK button title"), nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert show];
}

- (IBAction)showLoginIfNeeded;
{
    if (self.GitHub)
        return;

    NSString *username = [UICKeyChainStore stringForKey:kLEGitHubUsernameKey service:kLEGitHubServiceName];
    NSString *password = [UICKeyChainStore stringForKey:kLEGitHubPasswordKey service:kLEGitHubServiceName];
    if (username.length && password.length) {
        self.GitHub = [[UAGithubEngine alloc] initWithUsername:username password:password withReachability:YES];
        [self refreshIssues];
    } else
        [self showLogin];
}

- (IBAction)sync;
{// This should be the store's only external server API
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // TODO: Implement syncing refs #29

    // Get changes from GitHub
    // Add new items
    // Update exiting items

        // If changes, mark as conflicted, but do not update values

    // Push changes

        // If conflicts, notify user and cancel sync

        // If no changes, exit with success

        // Push new issues

        // Scrub placeholder data

        // Push new comments

        // Scrub placeholder data

        // ???: Can we push issues with comments already included?
}


#pragma mark Loading

- (void)loadIssues:(BOOL)freshStart;
{
    if (freshStart)
        [self removeContext];

    NSManagedObjectContext *context = self.managedObjectContext;
    [context.userInfo setValue:[NSDate date] forKey:kGHUpdatedDatePropertyName];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    NSDictionary *parameters = @{};
    [self.GitHub openIssuesForRepository:self.repositoryPath withParameters:parameters success:^(id results) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [results enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger index, BOOL *stop) {
            GHIssue *issue = [GHIssue issueNumber:[dictionary[kGHIssueNumberGitHubKey] integerValue] context:context];
            if (freshStart || issue.needsUpdating) {
                issue.lastUpdated = [NSDate date];
                [issue setValuesForKeysWithDictionary:dictionary];
            }
        }];
        [[GHStore sharedStore] save];
    } failure:handleError];

}

- (void)loadCommentsForIssue:(GHIssue *)issue;
{
    if (!issue.needsUpdating)
        return;
    else
        issue.lastUpdated = [NSDate date];

    if (!issue.commentsCount)
        return;

    __block NSMutableArray *comments = [NSMutableArray arrayWithCapacity:issue.commentsCount];

    void (^updateIssues)(NSArray *) = ^(NSArray *results){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        assert([results isKindOfClass:[NSArray class]]);
        [results enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger index, BOOL *stop) {
            GHComment *comment = [GHComment commentNumber:[dictionary[@"number"] integerValue] context:issue.managedObjectContext];
            [comment setValuesForKeysWithDictionary:dictionary];
            [comment setValue:issue forKey:kGHCommentIssuePropertyName];
            [comments addObject:comment];
        }];
        issue.comments = [NSOrderedSet orderedSetWithArray:comments];
        [[GHStore sharedStore] save];
    };

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [self.GitHub commentsForIssue:issue.number forRepository:self.repositoryPath success:updateIssues failure:handleError];
}

- (void)loadUser:(GHUser *)user;
{
    if (!user.needsUpdating)
        return;
    else
        user.lastUpdated = [NSDate date];

    void (^updateUser)(NSArray *) = ^(NSArray *results){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        assert([results isKindOfClass:[NSArray class]]);
        NSDictionary *dictionary = [results lastObject];
        assert([dictionary isKindOfClass:[NSDictionary class]]);
        [user setValuesForKeysWithDictionary:dictionary];
        [[GHStore sharedStore] save];
    };

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.GitHub user:user.userName success:updateUser failure:handleError];
}


#pragma mark Saving

- (void)deleteComment:(GHComment *)comment;
{
    if (IsEmpty(comment.body)) {
        [comment.managedObjectContext deleteObject:comment];
        [self save];
        return;
    }

    [self saveComment:comment];
}

- (void)deleteIssue:(GHIssue *)issue;
{
    if (IsEmpty(issue.body)) {
        [issue.managedObjectContext deleteObject:issue];
        [self save];
        return ;
    }

    [self saveIssue:issue];
}

- (void)saveComment:(GHComment *)comment;
{
    void (^deleteComment)(BOOL) = ^(BOOL deleted){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (deleted)
            [comment.managedObjectContext deleteObject:comment];

        [[GHStore sharedStore] save];
    };

    void (^updateComment)(NSArray *) = ^(NSArray *results){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        assert([results isKindOfClass:[NSArray class]]);
        NSDictionary *dictionary = [results lastObject];
        assert([dictionary isKindOfClass:[NSDictionary class]]);
        [comment setValuesForKeysWithDictionary:dictionary];
        comment.changes = nil;
        [[GHStore sharedStore] save];
    };

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (IsEmpty(comment.body) && !IsEmpty(comment.plainBody)) // Add
        [self.GitHub addComment:comment.plainBody toIssue:comment.issue.number forRepository:self.repositoryPath success:updateComment failure:handleError];
    else if (!IsEmpty(comment.body) && !IsEmpty(comment.plainBody)) // Edit
        [self.GitHub editComment:comment.commentID forRepository:self.repositoryPath withBody:comment.plainBody success:updateComment failure:handleError];
    else if (!IsEmpty(comment.body) && IsEmpty(comment.plainBody)) // Delete
        [self.GitHub deleteComment:comment.commentID forRepository:self.repositoryPath success:deleteComment failure:handleError];
    else // Unhandled states
        assert(NO);
}

- (void)saveIssue:(GHIssue *)issue;
{
    void (^deleteIssue)(BOOL) = ^(BOOL deleted){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (deleted)
            [issue.managedObjectContext deleteObject:issue];

        [[GHStore sharedStore] save];
    };

    void (^updateIssue)(NSArray *) = ^(NSArray *results){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        assert([results isKindOfClass:[NSArray class]]);
        NSDictionary *dictionary = [results lastObject];
        assert([dictionary isKindOfClass:[NSDictionary class]]);
        [issue setValuesForKeysWithDictionary:dictionary];
        issue.changes = nil;
        [[GHStore sharedStore] save];
    };

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (IsEmpty(issue.topic)) // Delete
        return [self.GitHub deleteIssue:issue.number inRepository:self.repositoryPath success:deleteIssue failure:handleError];

    NSDictionary *valuesForGitHubKeys = [issue dictionaryWithValuesForGitHubKeys:@[kLETalkTitleKey, kLETalkBodyKey]];
    if (IsEmpty(issue.title) && !IsEmpty(issue.plainBody)) // Add
        [self.GitHub addIssueForRepository:self.repositoryPath withDictionary:valuesForGitHubKeys success:updateIssue failure:handleError];
    else if (!IsEmpty(issue.body) && !IsEmpty(issue.plainBody)) // Edit
        [self.GitHub editIssue:issue.number inRepository:self.repositoryPath withDictionary:valuesForGitHubKeys success:updateIssue failure:handleError];
    else // Unhandled states
        assert(NO);
}

@end

NSString * const kGitHubDownStatusNotification = @"GitHub is down! (HTTP status 502)";
NSString * const kNetworkSlowStatusNotification = @"Network timed out (NSURLErrorDomain code -1001)";

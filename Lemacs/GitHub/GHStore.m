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

#import <UAGithubEngine/UAGithubEngine.h>
#import <UICKeyChainStore/UICKeyChainStore.h>


@interface GHStore ()

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, strong, readonly) NSURL *applicationDocumentsDirectory;
@property (nonatomic, strong, readonly) NSString *repositoryPath;

- (IBAction)removeContext;

@end


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
        NSLog(@"Dumping store due to error %@, %@", storeLoadingError, storeLoadingError.userInfo);
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
        NSLog(@"Store Deleting Error: %@, %@", storeDeletingError, storeDeletingError.userInfo);
}

- (IBAction)save;
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (!managedObjectContext || !managedObjectContext.hasChanges)
        return; // Abort

    NSError *contextSavingError;
    if ([managedObjectContext save:&contextSavingError])
        return; // Success

    if (kLEUseNarrativeLogging) {
        NSLog(@"Context Saving Error: %@, %@", contextSavingError, [contextSavingError userInfo]);

        NSString *whyThisHappened = @"abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.";
        NSLog(@"%@", whyThisHappened);

        NSString *whatShouldHappen = @"Replace this implementation with code to handle the error appropriately.";
        NSLog(@"%@", whatShouldHappen);
    }
    
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
    /* Syncing between Lemacs and GitHub
        1. Get changes from GitHub
        2. Add new items
        3. Update exiting items
            3a. If changes, mark as conflicted, but do not update values
        4. Push changes
            4a. If conflicts, notify user and cancel sync
            4a. If no changes, exit with success
        5. Re-start sync
     
     Lemacs edits do not change the actual values, but are stored locally until they can be push to the truth server. The changes are applied in the next sync cycle, and possibly retained until they can be confirmed as redundant. The acutal values are updated only from the truth server, so the changes are not reflected in the local data until they are part of the truth.
     If this is unnecessary caution and we can confirm the changes and apply them locally without getting them back from the server directly, we can skip this extra work.
     */
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
    } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"Failure %@", error.localizedDescription);
    }];

    [self save];
}

- (void)loadCommentsForIssue:(GHIssue *)issue;
{
    if (!issue.needsUpdating)
        return;
    else
        issue.lastUpdated = [NSDate date];

    if (!issue.commentsCount)
        return;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSMutableArray *comments = [NSMutableArray arrayWithCapacity:issue.commentsCount];

    [self.GitHub commentsForIssue:issue.number forRepository:self.repositoryPath success:^(id results) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [results enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger index, BOOL *stop) {
            GHComment *comment = [NSEntityDescription insertNewObjectForEntityForName:kGHCommentEntityName inManagedObjectContext:issue.managedObjectContext];
            [comment setValuesForKeysWithDictionary:dictionary];
            [comment setValue:issue forKey:kGHCommentIssuePropertyName];
            [comments addObject:comment];
        }];
    } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"%@ %@", NSStringFromSelector(_cmd), error.localizedDescription);
    }];

    issue.comments = [NSOrderedSet orderedSetWithArray:comments];
    [self save];
    //    [self.talkList reloadList];
}

- (void)loadUser:(GHUser *)user;
{
    if (!user.needsUpdating)
        return;
    else
        user.lastUpdated = [NSDate date];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    [self.GitHub user:user.userName success:^(id result) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        assert([result isKindOfClass:[NSArray class]]);
        NSDictionary *dictionary = [result lastObject];
        [user setValuesForKeysWithDictionary:dictionary];
    } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"%@ %@", NSStringFromSelector(_cmd), error.localizedDescription);
    }];
}

@end



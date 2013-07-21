//
//  GHStore.m
//  Lemacs
//
//  Created by Mike Lee on 7/21/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHStore.h"

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
    [self loadIssues];
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


#pragma mark Actions

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

- (IBAction)removeContext;
{
    NSURL *storeURL = [self.applicationDocumentsDirectory URLByAppendingPathComponent:@"Lemacs.sqlite"]; // FIXME: Factor out inline constants

    NSError *storeDeletingError = nil;
    if (![[NSFileManager defaultManager] removeItemAtURL:storeURL error:&storeDeletingError])
        NSLog(@"Store Deleting Error: %@, %@", storeDeletingError, storeDeletingError.userInfo);
}

- (IBAction)save;
{
    NSError *contextSavingError;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (!managedObjectContext || !managedObjectContext.hasChanges)
        return; // Abort

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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account" message:@"Sign in to GitHub" delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Ok", nil];
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
        [self loadIssues];
    } else
        [self showLogin];
}



#pragma mark Issues

- (void)loadIssues;
{
    [self removeContext];

    NSManagedObjectContext *context = self.managedObjectContext;

    NSDictionary *parameters = @{};
    [self.GitHub openIssuesForRepository:self.repositoryPath withParameters:parameters success:^(id results) {
        [results enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger index, BOOL *stop) {
            NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"GHIssue" inManagedObjectContext:context];

            [newManagedObject setValuesForKeysWithDictionary:dictionary];
        }];
    } failure:^(NSError *error) {
        NSLog(@"Failure %@", error.localizedDescription);
    }];

    [self save];
//    [self.talkList reloadList];
}

- (void)loadCommentsForIssue:(NSInteger)issueNumber;
{
    NSManagedObjectContext *context = self.managedObjectContext;

    NSDictionary *parameters = @{};
    [self.GitHub commentsForIssue:issueNumber forRepository:self.repositoryPath success:^(id results) {
        NSLog(@"Results: %@", results);
        [results enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger index, BOOL *stop) {
            NSLog(@"Dictionary: %@", dictionary);
//            NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"GHIssue" inManagedObjectContext:context];
//
//            [newManagedObject setValuesForKeysWithDictionary:issueDictionary];
        }];
    } failure:^(NSError *error) {
        NSLog(@"Failure %@", error.localizedDescription);
    }];

    [self save];
    //    [self.talkList reloadList];
}

@end

//
//  LEAppDelegate.m
//  Lemacs
//
//  Created by Mike Lee on 7/18/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//
// http://developer.github.com/v3/issues/

#import "LEAppDelegate.h"

#import "LETalkListController.h"
#import <UAGithubEngine/UAGithubEngine.h>
#import <UICKeyChainStore/UICKeyChainStore.h>


#ifdef HOCKEYAPP_IDENTIFIER
#import <HockeySDK/HockeySDK.h>
@interface LEAppDelegate () <BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate>
@end
#endif

@implementation LEAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef HOCKEYAPP_IDENTIFIER
    NSLog(@"hello");
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:HOCKEYAPP_IDENTIFIER delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
#endif
    
    [self showLoginIfNeeded];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
        self.talkList = (LETalkListController *)masterNavigationController.topViewController;
        self.talkList.managedObjectContext = self.managedObjectContext;
    } else {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        self.talkList = (LETalkListController *)navigationController.topViewController;
        self.talkList.managedObjectContext = self.managedObjectContext;
    }

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application;
{
    if (!kLEUseNarrativeLogging)
        return;

    NSLog(@"%@", NSStringFromSelector(_cmd));

    NSString *whyThisHappened = @"Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.";
    NSLog(@"%@", whyThisHappened);

    NSString *whatShouldHappen = @"Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.";
    NSLog(@"%@", whatShouldHappen);

    // TODO: Make this do what it's supposed to.
}

- (void)applicationDidEnterBackground:(UIApplication *)application;
{
    if (!kLEUseNarrativeLogging)
        return;

    NSLog(@"%@", NSStringFromSelector(_cmd));

    NSString *whyThisHappened = @"Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.";
    NSLog(@"%@", whyThisHappened);

    NSString *whatShouldHappen = @"If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.";
    NSLog(@"%@", whatShouldHappen);

    // TODO: Make this do what it's supposed to.
}

- (void)applicationWillEnterForeground:(UIApplication *)application;
{
    if (!kLEUseNarrativeLogging)
        return;

    NSLog(@"%@", NSStringFromSelector(_cmd));

    NSString *whyThisHappened = @"Called as part of the transition from the background to the inactive state.";
    NSLog(@"%@", whyThisHappened);

    NSString *whatShouldHappen = @"Here you can undo many of the changes made on entering the background";
    NSLog(@"%@", whatShouldHappen);

    // TODO: Make this do what it's supposed to.
}

- (void)applicationDidBecomeActive:(UIApplication *)application;
{
    if (!kLEUseNarrativeLogging)
        return;

    NSLog(@"%@", NSStringFromSelector(_cmd));

    NSString *whatShouldHappen = @"Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.";
    NSLog(@"%@", whatShouldHappen);

    // TODO: Make this do what it's supposed to.
}

- (void)applicationWillTerminate:(UIApplication *)application;
{
    if (!kLEUseNarrativeLogging)
        return;

    NSLog(@"%@", NSStringFromSelector(_cmd));

    NSString *whatShouldHappen = @"Saves changes in the application's managed object context before the application terminates.";
    NSLog(@"%@", whatShouldHappen);

    [self saveContext];
}



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

@synthesize managedObjectContext = _managedObjectContext, managedObjectModel = _managedObjectModel, persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)repositoryPath;
{
    return @"lemurs/Lemacs";
}


#pragma mark Core Data stack

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

- (IBAction)loadIssues;
{
    [self removeContext];

    NSManagedObjectContext *context = self.managedObjectContext;

    NSDictionary *parameters = @{};
    [self.GitHub openIssuesForRepository:self.repositoryPath withParameters:parameters success:^(id results) {
        [results enumerateObjectsUsingBlock:^(NSDictionary *issueDictionary, NSUInteger index, BOOL *stop) {
            NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"GHIssue" inManagedObjectContext:context];

            [newManagedObject setValuesForKeysWithDictionary:issueDictionary];
        }];
    } failure:^(NSError *error) {
        NSLog(@"Failure %@", error.localizedDescription);
    }];

    [self saveContext];
    [self.talkList reloadList];
}

- (IBAction)removeContext;
{
    NSURL *storeURL = [self.applicationDocumentsDirectory URLByAppendingPathComponent:@"Lemacs.sqlite"]; // FIXME: Factor out inline constants

    NSError *storeDeletingError = nil;
    if (![[NSFileManager defaultManager] removeItemAtURL:storeURL error:&storeDeletingError])
        NSLog(@"Store Deleting Error: %@, %@", storeDeletingError, storeDeletingError.userInfo);
}

- (IBAction)saveContext;
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


#pragma mark Account Management

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


#ifdef HOCKEYAPP_IDENTIFIER
- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
#ifndef CONFIGURATION_AppStore
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
    return nil;
}
#endif

@end

NSString * const kLEGitHubServiceName = @"com.github";
NSString * const kLEGitHubPasswordKey = @"password";
NSString * const kLEGitHubUsernameKey = @"username";

// Github issue params

// title
// Required string

// body
// Optional string

// assignee
// Optional string - Login for the user that this issue should be assigned to. NOTE: Only users with push access can set the assignee for new issues. The assignee is silently dropped otherwise.

//milestone
//Optional number - Milestone to associate this issue with. NOTE: Only users with push access can set the milestone for new issues. The milestone is silently dropped otherwise.

//labels
//Optional array of strings - Labels to associate with this issue. NOTE: Only users with push access can set labels for new issues. Labels are silently dropped otherwise.


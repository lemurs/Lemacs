//
//  LEAppDelegate.m
//  Lemacs
//
//  Created by Mike Lee on 7/18/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//
// http://developer.github.com/v3/issues/

#import "LEAppDelegate.h"

#import "GHStore.h"
#import "LETalkListController.h"

@implementation LEAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[GHStore sharedStore] showLoginIfNeeded];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
        self.talkList = (LETalkListController *)masterNavigationController.topViewController;
    } else {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        self.talkList = (LETalkListController *)navigationController.topViewController;
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

    [[GHStore sharedStore] save];
}

@end

//
//  APPAppDelegate.m
//  Appsterdam
//
//  Created by Klaas Speller on 7/18/13.
//  Copyright (c) 2013 Appsterdam. All rights reserved.
//

#import "APPAppDelegate.h"
#import <UAGithubEngine/UAGithubEngine.h>
#import <UICKeyChainStore/UICKeyChainStore.h>

@interface APPAppDelegate () <UIAlertViewDelegate>

@end


@implementation APPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account" message:@"Sign in to GitHub" delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert show];
    
    return YES;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSString *username = [(UITextField*)[alertView textFieldAtIndex:0] text];
    NSString *password = [(UITextField*)[alertView textFieldAtIndex:1] text];
    
    [UICKeyChainStore setString:username forKey:@"username" service:@"com.github"];
    [UICKeyChainStore setString:password forKey:@"password" service:@"com.github"];
    
    UAGithubEngine *engine = [[UAGithubEngine alloc] initWithUsername:username password:password withReachability:YES];

    NSDictionary *params = @{@"title": [NSString stringWithFormat:@"Issue %@", [NSDate new]],
                             @"body": @"Issues from iOS dude"
                             };
    [engine addIssueForRepository:@"lemurs/Lemacs" withDictionary:params success:^(id issue) {
        NSLog(@"success, %@", issue);
    } failure:^(NSError *error) {
        NSLog(@"failure %@", [error localizedDescription]);
    }];

    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end



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


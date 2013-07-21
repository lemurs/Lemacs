//
//  GHUser.m
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHUser.h"

@implementation GHUser

+ (NSDictionary *)GitHubKeysToPropertyNames;
{
    static NSDictionary *GitHubKeysToPropertyNames;
    if (GitHubKeysToPropertyNames)
        return GitHubKeysToPropertyNames;

    GitHubKeysToPropertyNames = @{@"avatar_url" : @"avatarURL",
                                  @"events_url" : @"eventsURL",
                                  @"followers_url" : @"followersURL",
                                  @"following_url" : @"followingURL",
                                  @"gists_url" : @"gistsURL",
                                  @"gravatar_id" : @"gravatarID",
                                  @"html_url" : @"htmlURL",
                                  @"id" : @"userID",
                                  @"login" : @"userName",
                                  @"organizations_url" : @"organizationsURL",
                                  @"received_events_url" : @"receivedEventsURL",
                                  @"repos_url" : @"reposURL",
                                  @"starred_url" : @"starredURL",
                                  @"subscriptions_url" : @"subscriptionsURL",
                                  @"type" : @"type",
                                  @"url" : @"userURL"};

    return GitHubKeysToPropertyNames;
}


#pragma mark - API

@dynamic avatarURL;

@synthesize avatar=_avatar;

- (UIImage *)avatar;
{
    if (_avatar)
        return _avatar;

    NSURL *imageURL = [NSURL URLWithString:self.avatarURL];
    NSError *imageLoadingError;
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL options:NSDataReadingUncached error:&imageLoadingError];
    if (!imageData)
        NSLog(@"Image Loading Error: %@", imageLoadingError.localizedDescription);

    return (_avatar = [UIImage imageWithData:imageData]);
}

@end

NSString * const kGHUserEntityName = @"GHUser";

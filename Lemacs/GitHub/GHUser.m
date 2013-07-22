//
//  GHUser.m
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHUser.h"
#import "GHStore.h"

@implementation GHUser

+ (NSDictionary *)GitHubKeysToPropertyNames;
{
    static NSDictionary *GitHubKeysToPropertyNames;
    if (GitHubKeysToPropertyNames)
        return GitHubKeysToPropertyNames;

    GitHubKeysToPropertyNames = @{@"avatar_url" : @"avatarURL",
                                  @"bio" : @"bio",
                                  @"blog" : @"blog",
                                  @"company" : @"company",
                                  @"created_at" : @"createdDate",
                                  @"email" : @"email",
                                  @"events_url" : @"eventsURL",
                                  @"followers" : @"followersCount",
                                  @"followers_url" : @"followersURL",
                                  @"following" : @"followingCount",
                                  @"following_url" : @"followingURL",
                                  @"gists_url" : @"gistsURL",
                                  @"gravatar_id" : @"gravatarID",
                                  @"hireable" : @"hireable",
                                  @"html_url" : @"htmlURL",
                                  @"id" : @"userID",
                                  @"location" : @"location",
                                  @"login" : @"userName",
                                  @"name" : @"fullName",
                                  @"organizations_url" : @"organizationsURL",
                                  @"public_repos" : @"reposCount",
                                  @"public_gists" : @"gistsCount",
                                  @"received_events_url" : @"receivedEventsURL",
                                  @"repos_url" : @"reposURL",
                                  @"starred_url" : @"starredURL",
                                  @"subscriptions_url" : @"subscriptionsURL",
                                  @"type" : @"type",
                                  @"updated_at" : @"modifiedDate",
                                  @"url" : @"userURL"};

    return GitHubKeysToPropertyNames;
}


#pragma mark - NSManagedObject

- (void)awakeFromInsert;
{
    // TODO: Load base url to receive complete configuration information
//    [[GHStore sharedStore] loadUser:self.userName];
}

#pragma mark - API

@dynamic avatarURL, fullName, userName;

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

- (NSString *)displayName;
{
    return self.fullName;
}

@end

NSString * const kGHUserEntityName = @"GHUser";

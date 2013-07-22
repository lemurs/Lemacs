//
//  GHPullRequest.m
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHPullRequest.h"

@implementation GHPullRequest

+ (NSDictionary *)GitHubKeysToPropertyNames;
{
    static NSDictionary *GitHubKeysToPropertyNames;
    if (GitHubKeysToPropertyNames)
        return GitHubKeysToPropertyNames;

    GitHubKeysToPropertyNames = @{@"diff_url" : @"diffURL",
                                  @"html_url" : @"htmlURL",
                                  @"id" : @"pullRequestID",
                                  @"patch_url" : @"patchURL"};

    return GitHubKeysToPropertyNames;
}


+ (NSString *)indexPropertyName;
{
    return kGHPullRequestIDPropertyName;
}

@end

NSString * const kGHPullRequestEntityName = @"GHPullRequest";
NSString * const kGHPullRequestIDPropertyName = @"pullRequestID";

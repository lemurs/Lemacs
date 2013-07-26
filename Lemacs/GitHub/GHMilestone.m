//
//  GHMilestone.m
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHMilestone.h"

@implementation GHMilestone

+ (NSDictionary *)GitHubKeysToPropertyNames;
{
    static NSDictionary *GitHubKeysToPropertyNames;
    if (GitHubKeysToPropertyNames)
        return GitHubKeysToPropertyNames;

    GitHubKeysToPropertyNames = @{@"number" : @"number"};

    return GitHubKeysToPropertyNames;
}

+ (NSString *)indexGitHubKey;
{
    return kGHMilestoneNumberGitHubKey;
}

@end

NSString * const kGHMilestoneEntityName = @"GHMilestone";

NSString * const kGHMilestoneNumberGitHubKey = @"number";
NSString * const kGHMilestoneNumberPropertyName = @"number";

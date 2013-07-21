//
//  GHLabel.m
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHLabel.h"

@implementation GHLabel

+ (NSDictionary *)GitHubKeysToPropertyNames;
{
    static NSDictionary *GitHubKeysToPropertyNames;
    if (GitHubKeysToPropertyNames)
        return GitHubKeysToPropertyNames;

    GitHubKeysToPropertyNames = @{@"color" : @"colorCode",
                                  @"name" : @"name",
                                  @"url" : @"labelURL"};

    return GitHubKeysToPropertyNames;
}

@end

NSString * const kGHLabelEntityName = @"GHLabel";

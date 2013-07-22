//
//  GHLabel.m
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "GHLabel.h"
#import "UIColor+HexCodes.h"

@implementation GHLabel

+ (instancetype)labelWithURL:(NSString *)labelURL context:(NSManagedObjectContext *)context;
{
    return [self objectWithEntityName:kGHLabelEntityName inContext:context properties:@{[self indexPropertyName] : labelURL}];
}


#pragma mark - GHManagedObject

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

+ (NSString *)indexPropertyName;
{
    return kGHLabelNamePropertyName;
}


#pragma mark - API

@dynamic colorCode, name, labelURL;

- (UIColor *)labelColor;
{
    return self.colorCode ? [UIColor colorWithHexCode:self.colorCode] : nil;
}

@end

NSString * const kGHLabelEntityName = @"GHLabel";
NSString * const kGHLabelNamePropertyName = @"name";

//
//  NSDate+GitHub.m
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "NSDate+GitHub.h"

@implementation NSDate (GitHub)

+ (NSDate *)dateWithGitHubDateString:(NSString *)dateString;
{
    static NSDateFormatter *GitHubDateFormatter;
    if (!GitHubDateFormatter) {
        GitHubDateFormatter = [[NSDateFormatter alloc] init];
        assert(GitHubDateFormatter);

        NSLocale * enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        assert(enUSPOSIXLocale);

        [GitHubDateFormatter setLocale:enUSPOSIXLocale];
        [GitHubDateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        [GitHubDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }

    return [GitHubDateFormatter dateFromString:dateString];
}

@end

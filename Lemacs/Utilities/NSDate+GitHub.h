//
//  NSDate+GitHub.h
//  Lemacs
//
//  Created by Mike Lee on 7/19/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@interface NSDate (GitHub)
+ (NSDateFormatter *)GitHubDateFormatter;
+ (NSDate *)dateWithGitHubDateString:(NSString *)dateString;
+ (NSString *)GitHubDateStringWithDate:(NSDate *)date;
@end

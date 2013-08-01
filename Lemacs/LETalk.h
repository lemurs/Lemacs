//
//  LETalk.h
//  Lemacs
//
//  Created by Mike Lee on 7/22/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@protocol LETalk <NSObject>
@property (nonatomic, readonly) BOOL hasChanges;
@property (nonatomic, readonly) NSAttributedString *styledBody, *styledTitle;
@property (nonatomic, readonly) NSString *bodyHTML, *displayedTime, *plainBody, *plainTitle;
@property (nonatomic, readonly) NSURL *baseURL;
@property (nonatomic, readonly) UIImage *avatar;
@end

static NSString * kLETalkBodyKey = @"body";
static NSString * kLETalkTitleKey = @"title";

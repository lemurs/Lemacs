//
//  LETalk.h
//  Lemacs
//
//  Created by Mike Lee on 7/22/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@protocol LETalk <NSObject>
@property (nonatomic, readonly) NSAttributedString *styledBody, *styledTitle;
@property (nonatomic, readonly) NSString *bodyHTML, *body, *displayedTime;
@property (nonatomic, readonly) NSURL *baseURL;
@property (nonatomic, readonly) UIImage *avatar;
@end

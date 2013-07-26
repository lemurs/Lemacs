//
//  LETalkCell.h
//  Lemacs
//
//  Created by Mike Lee on 7/21/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "LETalk.h"

@interface LETalkCell : UITableViewCell <UIWebViewDelegate>

+ (NSMutableDictionary *)URLsToWebViewHeights;

@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel, *titleLabel;
@property (nonatomic, weak) IBOutlet UIWebView *webView;

- (void)configureCellWithTalk:(id <LETalk>)talk;

@end

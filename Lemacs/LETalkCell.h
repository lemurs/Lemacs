//
//  LETalkCell.h
//  Lemacs
//
//  Created by Mike Lee on 7/21/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@interface LETalkCell : UITableViewCell <UIWebViewDelegate>

+ (NSMutableDictionary *)URLsToWebViewHeights;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

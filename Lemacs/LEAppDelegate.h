//
//  LEAppDelegate.h
//  Lemacs
//
//  Created by Mike Lee on 7/18/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@class LETalkListController;

@interface LEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) LETalkListController *talkList;
@property (strong, nonatomic) UIWindow *window;

@end

//
//  LETalkListController.h
//  Lemacs
//
//  Created by Mike Lee on 7/18/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@class LETalkViewController, UAGithubEngine;

@interface LETalkListController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) LETalkViewController *talkViewController;

- (IBAction)reloadList;

@end

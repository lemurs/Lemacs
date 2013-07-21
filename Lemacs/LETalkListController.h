//
//  LETalkListController.h
//  Lemacs
//
//  Created by Mike Lee on 7/18/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@class LETalkViewController, UAGithubEngine;

@interface LETalkListController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) LETalkViewController *talkViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UAGithubEngine *GitHub;

- (IBAction)reloadList;

@end

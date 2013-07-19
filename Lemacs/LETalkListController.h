//
//  LETalkListController.h
//  Lemacs
//
//  Created by Mike Lee on 7/18/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import <CoreData/CoreData.h>

@class LEWorkViewController;

@interface LETalkListController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) LEWorkViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

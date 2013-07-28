//
//  LETalkViewController.h
//  Lemacs
//
//  Created by Mike Lee on 7/18/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@class GHIssue, LEWorkViewController, UAGithubEngine;

@interface LETalkViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) GHIssue *issue;

@end

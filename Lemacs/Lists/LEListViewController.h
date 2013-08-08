//
//  LEListViewController.h
//  Lemacs
//
//  Created by Mike Lee on 8/8/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@interface LEListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

+ (NSString *)entityName;

@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchResults;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)reloadList;
- (IBAction)sortList:(UISegmentedControl *)sortControl;

@end

@interface LEAccountListController : LEListViewController
@end

@interface LEDocumentListController : LEListViewController
@end

@interface LELabelListController : LEListViewController
@end

@interface LERepositoryListController : LEListViewController
@end

@interface LESnippetListController : LEListViewController
@end

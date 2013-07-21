//
//  LETalkViewController.m
//  Lemacs
//
//  Created by Mike Lee on 7/18/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "LETalkViewController.h"

#import "GHComment.h"
#import "GHIssue.h"
#import "GHStore.h"
#import "LETalkCell.h"
#import "LEWorkViewController.h"
#import "UAGitHubEngine.h"
#import <sundown/SundownWrapper.h>

@interface LETalkViewController ()
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
- (IBAction)insertNewObject;
- (IBAction)saveContext;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end


@implementation LETalkViewController

#pragma mark - NSObject (UINibLoadingAdditions)

- (void)awakeFromNib;
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}


#pragma mark - UIViewController

- (void)viewDidLoad;
{
    [super viewDidLoad];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (LEWorkViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];

    NSLog(@"%@", NSStringFromSelector(_cmd));

    // TODO: Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
{
    if ([[segue identifier] isEqualToString:@"showWork"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}



#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller;
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;
{
    UITableView *tableView = self.tableView;

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.

 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSManagedObjectContext *context = self.fetchedResultsController.managedObjectContext;

    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            break;

        default:
            return;
    }

    [self saveContext];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
{
    // The table view should not be re-orderable.
    return NO;
}



#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.detailViewController.detailItem = object;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return section ? 0.0f : 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    if (section)
        return nil;

    UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    header.textLabel.text = self.issue.body;

    return header;
}


#pragma mark - API

@synthesize fetchedResultsController = _fetchedResultsController, managedObjectContext = _managedObjectContext;

- (NSFetchedResultsController *)fetchedResultsController;
{
    if (_fetchedResultsController)
        return _fetchedResultsController;

    NSPredicate *issuePredicate = [NSPredicate predicateWithFormat:@"issue == %@" argumentArray:@[self.issue]];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:kGHCommentEntityName inManagedObjectContext:self.managedObjectContext];
    fetchRequest.fetchBatchSize = 20;
    fetchRequest.predicate = issuePredicate;
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:kGHCreatedDatePropertyName ascending:YES]];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Comments"];
    fetchedResultsController.delegate = self;
    _fetchedResultsController = fetchedResultsController;

    NSError *fetchError = nil;
    if ([fetchedResultsController performFetch:&fetchError])
        return fetchedResultsController; // Success

    if (kLEUseNarrativeLogging) {
        NSLog(@"Fetch Error: %@, %@", fetchError, fetchError.userInfo);

        NSString *whyThisHappened = @"abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.";
        NSLog(@"%@", whyThisHappened);

        NSString *whatShouldHappen = @"Replace this implementation with code to handle the error appropriately.";
        NSLog(@"%@", whatShouldHappen);
    }

    // TODO: Make this do what it's supposed to.

    abort();

    return nil;
}

- (NSManagedObjectContext *)managedObjectContext;
{
    return self.issue.managedObjectContext;
}

- (IBAction)insertNewObject;
{
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:self.fetchedResultsController.fetchRequest.entity.name inManagedObjectContext:self.fetchedResultsController.managedObjectContext];

    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];

    [self saveContext];
}

- (IBAction)saveContext;
{
    NSError *contextSavingError;
    NSManagedObjectContext *managedObjectContext = self.fetchedResultsController.managedObjectContext;
    if (!managedObjectContext || !managedObjectContext.hasChanges)
        return; // Abort

    if ([managedObjectContext save:&contextSavingError])
        return; // Success

    if (kLEUseNarrativeLogging) {
        NSLog(@"Context Saving Error: %@, %@", contextSavingError, [contextSavingError userInfo]);

        NSString *whyThisHappened = @"abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.";
        NSLog(@"%@", whyThisHappened);

        NSString *whatShouldHappen = @"Replace this implementation with code to handle the error appropriately.";
        NSLog(@"%@", whatShouldHappen);
    }

    // TODO: Make this do what it's supposed to.

    abort();
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{

    GHComment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *htmlString = [SundownWrapper convertMarkdownString:comment.body];
    [((LETalkCell *)cell).webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@""]];
}

@end


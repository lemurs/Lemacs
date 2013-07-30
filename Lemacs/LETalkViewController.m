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
#import "GHUser.h"
#import "LETalk.h"
#import "LETalkCell.h"
#import "LEWorkViewController.h"
#import "SETextView.h"
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

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([LETalkCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([LETalkCell class])];
}

- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];

    NSLog(@"%@", NSStringFromSelector(_cmd));

    // TODO: Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
{
    if ([[segue identifier] isEqualToString:@"SelectTalk"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        id <LETalk> talk = (indexPath.section < self.fetchedResultsController.sections.count) ? [self.fetchedResultsController objectAtIndexPath:indexPath] : self.issue;
        assert([talk conformsToProtocol:@protocol(LETalk)]);
        assert([segue.destinationViewController isKindOfClass:[LEWorkViewController class]]);
        [[segue destinationViewController] setTalk:talk];
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
    return self.fetchedResultsController.sections.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section < self.fetchedResultsController.sections.count) {
        id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
        return sectionInfo.numberOfObjects;
    } else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LETalkCell class]) forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == self.fetchedResultsController.sections.count)
        return;

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
    return NO;
}



#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [self performSegueWithIdentifier:@"SelectTalk" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    id <LETalk> talk = (indexPath.section < self.fetchedResultsController.sections.count) ? [self.fetchedResultsController objectAtIndexPath:indexPath] : self.issue;
    assert([talk conformsToProtocol:@protocol(LETalk)]);

    return CGRectGetHeight([SETextView frameRectWithAttributtedString:talk.styledBody constraintSize:CGSizeMake(264.0f, 1024.0f)]) + 29.0f; // 21.0f for the label plus 8 for the padding
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
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:kGHCreatedDatePropertyName ascending:NO]];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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
    [newManagedObject setValue:[NSDate date] forKey:kGHCreatedDatePropertyName];
    [newManagedObject setValue:[NSDate distantPast] forKey:kGHUpdatedDatePropertyName];

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
    assert([cell isKindOfClass:[LETalkCell class]]);
    LETalkCell *talkCell = (LETalkCell *)cell;

    id <LETalk> talk = (indexPath.section < self.fetchedResultsController.sections.count) ? [self.fetchedResultsController objectAtIndexPath:indexPath] : self.issue;
    assert([talk conformsToProtocol:@protocol(LETalk)]);

    [talkCell configureCellWithTalk:talk];
    talkCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end


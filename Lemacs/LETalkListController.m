//
//  LETalkListController.m
//  Lemacs
//
//  Created by Mike Lee on 7/18/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

#import "LETalkListController.h"

#import "GHIssue.h"
#import "GHStore.h"
#import "GHUser.h"
#import "LETalk.h"
#import "LETalkCell.h"
#import "LETalkViewController.h"
#import "SETextView.h"
#import "UIGestureRecognizer+LEDebugging.h"

typedef enum {kLETalkSizeMini, kLETalkSizeRegular, kLETalkSizeLarge, kLETalkSizeFull, kLETalkSizeCount} LETalkSize;

@interface LETalkListController ()

@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) LETalkSize talkSize;

- (IBAction)insertNewObject;
- (IBAction)saveContext;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation LETalkListController

+ (void)initialize;
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kLETalkListTalkSize : @(kLETalkSizeRegular)}];
}


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

    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([LETalkCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([LETalkCell class])];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.talkViewController = (LETalkViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    } else {
        self.talkViewController = (LETalkViewController *)[self.navigationController topViewController];
    }

    self.talkViewController = (LETalkViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    self.talkSize = [[NSUserDefaults standardUserDefaults] integerForKey:kLETalkListTalkSize];
}

- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];

    NSLog(@"%@", NSStringFromSelector(_cmd));

    // TODO: Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
{
    if ([[segue identifier] isEqualToString:@"SelectIssue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        GHIssue *issue = (GHIssue *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        assert([issue isKindOfClass:[GHIssue class]]);
        [[GHStore sharedStore] loadCommentsForIssue:issue];

        assert([segue.destinationViewController isKindOfClass:[LETalkViewController class]]);
        LETalkViewController *talkViewController = (LETalkViewController *)segue.destinationViewController;
        talkViewController.issue = issue;
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
    [self performSegueWithIdentifier:@"SelectIssue" sender:[tableView cellForRowAtIndexPath:indexPath]];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        if ([object isKindOfClass:[GHIssue class]]) {
            GHIssue *issue = (GHIssue *)object;
            [[GHStore sharedStore] loadCommentsForIssue:issue];
            self.talkViewController.issue = issue;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    id <LETalk> talk = [self.fetchedResultsController objectAtIndexPath:indexPath];
    assert([talk conformsToProtocol:@protocol(LETalk)]);

    static const CGFloat heightMin = 42.0; // Height of the avatar
    CGFloat heightMax = heightMin;
    switch (self.talkSize) {
        case kLETalkSizeMini:
            return heightMin;

        case kLETalkSizeRegular:
            heightMax = 84.0f;
            break;

        case kLETalkSizeLarge:
            heightMax = 264.0f;
            break;

        case kLETalkSizeFull:
            heightMax = 1024.0f;
            break;

        default:
            break;
    }

    return MIN(MAX(CGRectGetHeight([SETextView frameRectWithAttributtedString:talk.styledBody constraintSize:CGSizeMake(264.0f, heightMax)]), heightMin), heightMax) + 29.0f; // 21.0f for the label plus 8 for the padding
}


#pragma mark - API

@synthesize fetchedResultsController = _fetchedResultsController, managedObjectContext = _managedObjectContext;

- (NSFetchedResultsController *)fetchedResultsController;
{
    if (_fetchedResultsController)
        return _fetchedResultsController;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:kGHIssueEntityName inManagedObjectContext:self.managedObjectContext];
    fetchRequest.fetchBatchSize = 20;
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:kGHCreatedDatePropertyName ascending:NO]];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    fetchedResultsController.delegate = self;
    _fetchedResultsController = fetchedResultsController;

    NSError *fetchError;
    if ([fetchedResultsController performFetch:&fetchError]) {
        if (!self.fetchedResultsController.sections.count)
            [[GHStore sharedStore] loadIssues:YES];

        return fetchedResultsController; // Success
    }

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
{// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
    if (_managedObjectContext)
        return _managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [[GHStore sharedStore] persistentStoreCoordinator];
    if (coordinator) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
    }

    return _managedObjectContext;
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

- (IBAction)reloadList;
{
    [self.tableView reloadData];
}

- (IBAction)resizeCells:(UIPinchGestureRecognizer *)pinch;
{
    BOOL embiggens = pinch.velocity > 0.0f;
    BOOL jumps = fabs(pinch.velocity) > 6.0;

    if (jumps) {
        self.talkSize = embiggens ? kLETalkSizeFull : kLETalkSizeFull;
        [self reloadList];
        return;
    }

    if (pinch.scale < 0.0f)
        self.talkSize = kLETalkSizeMini;
    else if (pinch.scale > 5.0f)
        self.talkSize = kLETalkSizeFull;
    else if (pinch.scale > 3.0f)
        self.talkSize = kLETalkSizeLarge;
    else
        self.talkSize = kLETalkSizeRegular;

//    NSLog(@"Scale: %f, Velocity: %f", pinch.scale, pinch.velocity);
//    NSLog(@"State: %@", pinch.stateName);
}

- (void)setTalkSize:(LETalkSize)talkSize;
{
    if (_talkSize == talkSize)
        return;

    _talkSize = talkSize;
    [self.tableView reloadData];
    [[NSUserDefaults standardUserDefaults] setInteger:talkSize forKey:kLETalkListTalkSize];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
{
    LETalkCell *talkCell = (LETalkCell *)cell;
    assert([talkCell isKindOfClass:[LETalkCell class]]);

    id <LETalk> talk = [self.fetchedResultsController objectAtIndexPath:indexPath];
    assert([talk conformsToProtocol:@protocol(LETalk)]);

    [talkCell configureCellWithTalk:talk];
}

@end

NSString * const kLETalkListTalkSize = @"LETalkList-TalkSize";

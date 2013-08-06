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
#import "NSError+LEPresenting.h"
#import "SETextView.h"
#import "UAGitHubEngine.h"
#import <sundown/SundownWrapper.h>

@interface LETalkViewController ()

@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) BOOL reverseSort;

- (IBAction)insertNewObject;
- (IBAction)reloadList;
- (IBAction)saveContext;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end


@implementation LETalkViewController

+ (void)initialize;
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kLETalkViewSortOrder : @(NO)}];
}


#pragma mark - NSObject (UINibLoadingAdditions)

- (void)awakeFromNib;
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
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

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];

    self.reverseSort = [[NSUserDefaults standardUserDefaults] integerForKey:kLETalkViewSortOrder];

    [self reloadList];

    if (self.tableView.numberOfSections && [self.tableView numberOfRowsInSection:0])
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
}

- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];

    NSLog(@"%@", NSStringFromSelector(_cmd));

    // TODO: Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
{
    id <LETalk> talk;

    if ([[segue identifier] isEqualToString:@"SelectTalk"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        talk = (indexPath.section < self.fetchedResultsController.sections.count) ? [self.fetchedResultsController objectAtIndexPath:indexPath] : self.issue;
        assert([talk conformsToProtocol:@protocol(LETalk)]);
    } else if ([[segue identifier] isEqualToString:@"CreateComment"])
        talk = [self.issue addComment];
    else
        assert(NO);

    UIViewController *destinationViewController = segue.destinationViewController;
    if ([destinationViewController isKindOfClass:[UINavigationController class]])
        destinationViewController = ((UINavigationController *)destinationViewController).topViewController;

    assert([destinationViewController isKindOfClass:[LEWorkViewController class]]);
    ((LEWorkViewController *)destinationViewController).talk = talk;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (section == 0) {
        return self.issue.topic;
    } else
        return nil;
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

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    [self performSegueWithIdentifier:@"SelectTalk" sender:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    id <LETalk> talk = (indexPath.section < self.fetchedResultsController.sections.count) ? [self.fetchedResultsController objectAtIndexPath:indexPath] : self.issue;
    assert([talk conformsToProtocol:@protocol(LETalk)]);

    return MAX(64.0f, CGRectGetHeight([SETextView frameRectWithAttributtedString:talk.styledBody constraintSize:CGSizeMake(264.0f, 1024.0f)]) + 29.0f); // 21.0f for the label plus 8 for the padding
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return section ? 12.0f : 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return section ? 0.0f : 30.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section;
{
    assert([view isKindOfClass:[UITableViewHeaderFooterView class]]);
    UITableViewHeaderFooterView *footerView = (UITableViewHeaderFooterView *)view;
    footerView.contentView.backgroundColor = tableView.backgroundColor;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section;
{
    assert([view isKindOfClass:[UITableViewHeaderFooterView class]]);
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.contentView.backgroundColor = tableView.backgroundColor;
    headerView.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
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
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:kGHCreatedDatePropertyName ascending:self.reverseSort]];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    fetchedResultsController.delegate = self;

    _fetchedResultsController = fetchedResultsController;

    return fetchedResultsController;
}

- (NSManagedObjectContext *)managedObjectContext;
{
    return self.issue.managedObjectContext;
}

- (void)setReverseSort:(BOOL)reverseSort;
{
    if (_reverseSort == reverseSort)
        return;

    _reverseSort = reverseSort;
    [self reloadList];
    [[NSUserDefaults standardUserDefaults] integerForKey:kLETalkViewSortOrder];
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

- (IBAction)reloadList;
{
    // If we switch from [^|v] to [v|^] change self.reverseSort to !self.reverseSort
    self.fetchedResultsController.fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:kGHCreatedDatePropertyName ascending:self.reverseSort]];

    NSError *fetchError;
    if (![self.fetchedResultsController performFetch:&fetchError]) {
        [fetchError present];
        return;
    }

    if (self.fetchedResultsController.sections.count)
        [self.tableView reloadData];
    else
        [[GHStore sharedStore] loadIssues:YES];

    [self.refreshControl endRefreshing];
}

- (IBAction)saveContext;
{
    NSError *contextSavingError;
    NSManagedObjectContext *managedObjectContext = self.fetchedResultsController.managedObjectContext;
    if (!managedObjectContext || !managedObjectContext.hasChanges)
        return; // Abort

    if ([managedObjectContext save:&contextSavingError])
        return; // Success

    [contextSavingError present];

    // TODO: Make this do what it's supposed to.

    abort();
}

- (IBAction)sortList:(UISegmentedControl *)sortControl;
{
    if (self.reverseSort != sortControl.selectedSegmentIndex)
        self.reverseSort = sortControl.selectedSegmentIndex;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    assert([cell isKindOfClass:[LETalkCell class]]);
    LETalkCell *talkCell = (LETalkCell *)cell;

    id <LETalk> talk = (indexPath.section < self.fetchedResultsController.sections.count) ? [self.fetchedResultsController objectAtIndexPath:indexPath] : self.issue;
    assert([talk conformsToProtocol:@protocol(LETalk)]);

    [talkCell configureCellWithTalk:talk];
    talkCell.accessoryType = UITableViewCellAccessoryNone;
}

@end

NSString * const kLETalkViewSortOrder = @"LETalkView-ReverseSort";

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
#import "LEWorkViewController.h"
#import "SETextView.h"
#import "NSError+LEPresenting.h"
#import "UIGestureRecognizer+LEDebugging.h"

typedef enum {kLETalkSizeMini, kLETalkSizeRegular, kLETalkSizeLarge, kLETalkSizeFull, kLETalkSizeCount} LETalkSize;

@interface LETalkListController ()

@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) BOOL reverseSort;
@property (nonatomic) LETalkSize talkSize;

- (IBAction)saveContext;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation LETalkListController

+ (void)initialize;
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kLETalkListTalkSize : @(kLETalkSizeRegular), kLETalkListSortOrder : @(NO)}];
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

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([LETalkCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([LETalkCell class])];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.talkViewController = (LETalkViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    } else {
        self.talkViewController = (LETalkViewController *)[self.navigationController topViewController];
    }

    self.talkViewController = (LETalkViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    self.reverseSort = [[NSUserDefaults standardUserDefaults] integerForKey:kLETalkListSortOrder];
    self.talkSize = [[NSUserDefaults standardUserDefaults] integerForKey:kLETalkListTalkSize];
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    [self reloadList];
}

- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];

    NSLog(@"%@", NSStringFromSelector(_cmd));

    // TODO: Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
{
    GHIssue *issue;
    if ([[segue identifier] isEqualToString:@"CreateIssue"]) {
        issue = [GHIssue newIssueInContext:self.managedObjectContext];
        assert([segue.destinationViewController isKindOfClass:[LEWorkViewController class]]);
        [[segue destinationViewController] setTalk:issue];
        return;
    }

    LETalkCell *cell = sender;
    assert([cell isKindOfClass:[LETalkCell class]]);

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    issue = (GHIssue *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    assert([issue isKindOfClass:[GHIssue class]]);

    UIViewController *destinationViewController = segue.destinationViewController;
    if ([destinationViewController isKindOfClass:[UINavigationController class]])
        destinationViewController = ((UINavigationController *)destinationViewController).topViewController;

    if ([segue.identifier isEqualToString:@"SelectIssue"]) {
        [[GHStore sharedStore] loadCommentsForIssue:issue];
        assert([destinationViewController isKindOfClass:[LETalkViewController class]]);
        LETalkViewController *talkViewController = (LETalkViewController *)destinationViewController;
        talkViewController.issue = issue;
        talkViewController.navigationItem.prompt = issue.topic;
    } else if ([segue.identifier isEqualToString:@"SelectTalk"]) {
        assert([destinationViewController isKindOfClass:[LEWorkViewController class]]);
        ((LEWorkViewController *)destinationViewController).talk = issue;
    }

}



#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}



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


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
{
    [self performSegueWithIdentifier:@"SelectTalk" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryDetailDisclosureButton)
        [self performSegueWithIdentifier:@"SelectIssue" sender:cell];
    else
        [self performSegueWithIdentifier:@"SelectTalk" sender:cell];
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

#pragma mark Properties

@synthesize fetchedResultsController = _fetchedResultsController, managedObjectContext = _managedObjectContext;

- (NSFetchedResultsController *)fetchedResultsController;
{
    if (_fetchedResultsController)
        return _fetchedResultsController;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:kGHIssueEntityName inManagedObjectContext:self.managedObjectContext];
    fetchRequest.fetchBatchSize = 20;
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:kGHCreatedDatePropertyName ascending:self.reverseSort]];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    fetchedResultsController.delegate = self;

    _fetchedResultsController = fetchedResultsController;

    return fetchedResultsController;
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

- (void)setReverseSort:(BOOL)reverseSort;
{
    if (_reverseSort == reverseSort)
        return;

    _reverseSort = reverseSort;
    [self reloadList];
    [[NSUserDefaults standardUserDefaults] integerForKey:kLETalkListSortOrder];
}

- (void)setTalkSize:(LETalkSize)talkSize;
{
    if (_talkSize == talkSize)
        return;

    _talkSize = talkSize;
    [self.tableView reloadData];
    [[NSUserDefaults standardUserDefaults] setInteger:talkSize forKey:kLETalkListTalkSize];
}


#pragma mark Actions

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
}

- (IBAction)resizeCells:(UIPinchGestureRecognizer *)pinch;
{
    BOOL embiggens = pinch.velocity > 0.0f; // Gets bigger, versus gets smaller
    BOOL jumps = fabs(pinch.velocity) > 6.0; // High velocity jumps between full stops

    if (jumps) {
        self.talkSize = embiggens ? kLETalkSizeFull : kLETalkSizeFull;
        [self.tableView reloadData];
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

- (IBAction)showOptions:(UIBarButtonItem *)barButton;
{
    // TODO: Implement the options menu, refs #25
    NSLog(@"TODO: Implement %@ refs #%d", NSStringFromSelector(_cmd), 25);
}

- (IBAction)sortList:(UISegmentedControl *)sortControl;
{
    if (self.reverseSort != sortControl.selectedSegmentIndex)
        self.reverseSort = sortControl.selectedSegmentIndex;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
{
    LETalkCell *talkCell = (LETalkCell *)cell;
    assert([talkCell isKindOfClass:[LETalkCell class]]);

    id <LETalk> talk = [self.fetchedResultsController objectAtIndexPath:indexPath];
    assert([talk conformsToProtocol:@protocol(LETalk)]);

    [talkCell configureCellWithTalk:talk];

    GHIssue *issue = (GHIssue *)talk;
    assert([issue isKindOfClass:[GHIssue class]]);

    NSInteger commentsCount = issue.commentsCount;
    if (commentsCount) {
        talkCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        talkCell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TalkDisclosure"]];
    } else {
        talkCell.accessoryType = UITableViewCellAccessoryNone;
        talkCell.accessoryView = nil;
    }
}

@end

NSString * const kLETalkListSortOrder = @"LETalkList-ReverseSort";
NSString * const kLETalkListTalkSize = @"LETalkList-TalkSize";

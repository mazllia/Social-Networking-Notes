//
//  FriendTVC.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/12/3.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "FriendTVC.h"
#import "FriendCell.h"

#import "Contact.h"

#import "ServerSynchronizer.h"
#import "DatabaseManagedDocument.h"

@interface FriendTVC ()

@end

@implementation FriendTVC

- (void)viewDidLoad
{
	[super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFinished) name:ServerSynchronizerNotificationContactSynced object:nil];
	[self databaseReady];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)refresh:(UIRefreshControl *)sender
{
	[[ServerSynchronizer sharedSynchronizer] sync];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (IBAction)organizeTapped:(id)sender
{
	
}

- (void)refreshFinished
{
	[self.refreshControl endRefreshing];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)databaseReady
{
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
	[fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"isVIP" ascending:YES]]];
	
	self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																		managedObjectContext:[DatabaseManagedDocument sharedDatabase].managedObjectContext
																		  sectionNameKeyPath:nil
																				   cacheName:nil];
}

- (void)finishSelectContacts
{
	NSMutableArray *result = [NSMutableArray array];
	for (NSIndexPath *selected in [self.tableView indexPathsForSelectedRows]) {
		[result addObject:((FriendCell *)[self.tableView cellForRowAtIndexPath:selected]).contact];
	}
	[self.selectDelegate friendTVC:self didSelectContacts:result];
}

#pragma mark - UITV Data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendTableCell";
	FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	cell.contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
		
	return cell;
}

#pragma mark - UITV Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	FriendCell *friendCell = (FriendCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	NSLog(@"%@", friendCell.contact);
}

@end

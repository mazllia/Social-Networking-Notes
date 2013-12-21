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

#pragma mark - UITV Data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendTableCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	Contact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	FBProfilePictureView *fbPictureView = [cell viewWithTag:3];
	fbPictureView.profileID = contact.fbUid;
	
	UILabel *title = [cell viewWithTag:1];
	title.text = contact.nickName? contact.nickName: contact.fbName;
	
	UISwitch *vip = [cell viewWithTag:2];
	vip.on = [contact.isVIP boolValue];
	
	return cell;
}

#pragma mark - UITV Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	FriendCell *friendCell = [self.tableView cellForRowAtIndexPath:indexPath];
	NSLog(@"%@", friendCell.contact);
}

@end

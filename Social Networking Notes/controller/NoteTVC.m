//
//  NoteTVC.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/9/15.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "NoteTVC.h"
#import "Note+Create.h"
#import "Contact+Create.h"
#import "Multimedia+Create.h"

#import "ServerCommunicator.h"
#import "DatabaseManagedDocument.h"

#import "NoteDetailTVC.h"
#import "NoteCell.h"

#import "ServerSynchronizer.h"

@interface NoteTVC ()

@end

@implementation NoteTVC

- (void)viewDidLoad
{
	[super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFinished) name:ServerSynchronizerNotificationNoteSynced object:nil];
	[self databaseReady];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)refresh:(UIRefreshControl *)sender {
	[[ServerSynchronizer sharedSynchronizer] sync];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)refreshFinished
{
	[self.refreshControl endRefreshing];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)databaseReady
{
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
	[fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dueTime" ascending:YES]]];
	
	self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																		managedObjectContext:[DatabaseManagedDocument sharedDatabase].managedObjectContext
																		  sectionNameKeyPath:nil
																				   cacheName:nil];
}

- (IBAction)readTestFile:(id)sender {
	NSError *err;
	NSArray *noteArray = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:@"/Users/Mazllia/Downloads/testStick.txt"] options:nil error:&err];
	NSArray *contactArray = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:@"/Users/Mazllia/Downloads/testContact.txt"] options:nil error:&err];
	NSManagedObjectContext *managedObjectContext = [DatabaseManagedDocument sharedDatabase].managedObjectContext;

	[managedObjectContext performBlockAndWait:^{

		// Insert or update new
		for (NSDictionary *contactDictionary in contactArray) {
			Contact *newContact = [Contact contactWithServerInfo:contactDictionary inManagedObjectContext:managedObjectContext];
		}

		for (NSDictionary *noteDictionary in noteArray) {
			Contact *sender = [Contact contactWithServerInfo:@{ServerContactUID: noteDictionary[ServerNoteSenderUID]} inManagedObjectContext:managedObjectContext];

			NSMutableArray *receivers = [NSMutableArray arrayWithCapacity:[(NSArray *)noteDictionary[ServerNoteReceiverList] count]];
			for (NSDictionary *receiverInfo in noteDictionary[ServerNoteReceiverList]) {
				Contact *receiver = [Contact contactWithServerInfo:@{ServerContactUID: receiverInfo[ServerNoteReceiverUID]} inManagedObjectContext:managedObjectContext];
				[receivers addObject:receiver];
			}

			NSMutableArray *multimedia = [NSMutableArray arrayWithCapacity:[(NSArray *)noteDictionary[ServerMediaFileList] count]];
			for (NSDictionary *multimediaInfo in noteDictionary[ServerMediaFileList]) {
				Multimedia *multimedium = [Multimedia multimediaWithServerInfo:multimediaInfo data:nil inManagedObjectContext:managedObjectContext];
				[multimedia addObject:multimedium];
			}

			Note *newNote = [Note noteWithServerInfo:noteDictionary sender:sender receivers:receivers media:multimedia inManagedObjectContext:managedObjectContext];
		}

		DatabaseManagedDocument *db = [DatabaseManagedDocument sharedDatabase];
		[db saveToURL:db.fileURL  forSaveOperation:UIDocumentSaveForOverwriting completionHandler:nil];
		
	}];
}

#pragma mark - UITV Data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NoteTableCell";
	NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	cell.note = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	return cell;
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NoteDetailTVC *noteDetailTVC = (NoteDetailTVC *)segue.destinationViewController;
	if ([segue.identifier isEqualToString:@"Show Note"]) {
		noteDetailTVC.note = ((NoteCell *)sender).note;
	} else if ([segue.identifier isEqualToString:@"Create Note"]) {		
		NSManagedObjectContext *context = [DatabaseManagedDocument sharedDatabase].managedObjectContext;
		Note *newNote = [Note noteWithTitle:@"Title" location:@"Location" dueTime:[NSDate date] receivers:nil media:nil inManagedObjectContext:context];
		noteDetailTVC.note = newNote;
	}
}

@end

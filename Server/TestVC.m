//
//  TestVC.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/5.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "TestVC.h"
#import "DatabaseManagedDocument.h"
#import "FBCommunicator.h"

#import "ServerCommunicator.h" // For parsing only

#import "ServerSynchronizer.h"

#import "Contact+Create.h"
#import "Note+Create.h"
#import "Multimedia+Create.h"

@interface TestVC ()

@property (weak, nonatomic) id<FBGraphUser> me;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (weak, nonatomic) IBOutlet UIButton *friendListButtom;
@property (weak, nonatomic) IBOutlet UILabel *yourID;
@property (weak, nonatomic) IBOutlet UIButton *parseJSONButton;

- (IBAction)parseJSON;
- (IBAction)buttonTapped;
- (IBAction)readJSON;

@end

@implementation TestVC

- (void)viewDidLoad
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:DatabaseManagedDocumentNotificationReady object:[DatabaseManagedDocument sharedDatabase]];
}

- (void)save{
	NSLog(@"OKAY!");
}

- (IBAction)parseJSON
{
	NSArray *array = [FBCommunicator sharedCommunicator].friendsInfo;
	
	ServerSynchronizer *serverSync = [ServerSynchronizer sharedSynchronizer];
	Contact *whoIsMe = [serverSync currentUser];
	serverSync.autoSyncTimeInterval = 300;
	[serverSync sync];
}

- (IBAction)readJSON
{
	NSError *err;
	NSArray *noteArray = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:@"/Users/Mazllia/Downloads/testStick.txt"] options:nil error:&err];
	NSArray *contactArray = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:@"/Users/Mazllia/Downloads/testContact.txt"] options:nil error:&err];
	NSManagedObjectContext *managedObjectContext = [DatabaseManagedDocument sharedDatabase].managedObjectContext;
	
//	Contact *sender = [Contact contactWithServerInfo:@{ServerContactUID: noteArray[0][ServerNoteSenderUID]} inManagedObjectContext:managedObjectContext];
	
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

- (IBAction)buttonTapped
{
	FBFriendPickerViewController *friendVC = [[FBFriendPickerViewController alloc] init];
	[friendVC loadData];
	[friendVC presentModallyFromViewController:self animated:YES handler:^(FBViewController *sender, BOOL donePressed) {
		NSString *message;
		if (donePressed) {
			if (![friendVC.selection count]) {
				message = @"You did not select anyone.";
			} else {
				message = [NSString stringWithFormat:@"You've selected %i friend(s).", [friendVC.selection count]];
			}
			[[[UIAlertView alloc] initWithTitle:@"Friends:" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		}
	}];
}

- (IBAction)readJSON:(id)sender {
}

- (id<FBGraphUser>)me
{
	return [FBCommunicator sharedCommunicator].me;
}

- (void)setMe:(id<FBGraphUser>)me
{
	[FBCommunicator sharedCommunicator].me = me;
}

#pragma mark - FBLoginView Delegate

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
	[[[UIAlertView alloc] initWithTitle:@"FBLoginError" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Okay, debug time!" otherButtonTitles: nil] show];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
	self.me = user;
	self.yourID.text = [user id];
	self.profilePictureView.profileID = user.id;
	self.userName.text = user.name;
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
	self.friendListButtom.enabled = YES;
	self.parseJSONButton.enabled = YES;
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
	self.me = nil;
	self.yourID.text = nil;
	self.profilePictureView.profileID = nil;
	self.userName.text = @"";
	self.friendListButtom.enabled = NO;
	self.parseJSONButton.enabled = NO;
}

@end

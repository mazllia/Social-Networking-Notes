//
//  TestVC.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/5.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "TestVC.h"
#import <FacebookSDK/FacebookSDK.h>
//#import "DatabaseManagedDocument.h"
//#import "ServerCommunicator.h"
//#import "Contact+Create.h"
//#import "Note+Create.h"

@interface TestVC ()
@property (strong, nonatomic) id<FBGraphUser> user;

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (weak, nonatomic) IBOutlet UIButton *friendListButtom;

- (IBAction)buttonTapped;
@end

@implementation TestVC

- (void)viewDidLoad
{
//	self.fbLoginView.readPermissions = @[@"basic_info"];
}

- (IBAction)buttonTapped
{
//	ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
//	NSDictionary *noteInfo = @{ServerNoteDueTime: [NSDate new],
//							   ServerNoteLocation: @"here",
//							   ServerNoteCreateTime: [NSDate new]
//							   };
//	Contact *aContact = [Contact contactWithServerInfo:@{ServerContactUID: @"1", ServerContactFbAccountIdentifier: @"1823"} inManagedObjectContext:[DatabaseManagedDocument sharedDatabase].managedObjectContext];
//	NSArray *receiver = @[aContact];
//	Note *aNote = [Note noteWithServerInfo:noteInfo sender:aContact receivers:receiver media:nil inManagedObjectContext:[DatabaseManagedDocument sharedDatabase].managedObjectContext];
//	[serverCommunicator pushNotes:aNote toReceivers: [aNote.recievers allObjects]];
	
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

#pragma mark - FBLoginView Delegate

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
	[[[UIAlertView alloc] initWithTitle:@"FBLoginError" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Okay, debug time!" otherButtonTitles: nil] show];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
	self.user = user;
	self.profilePictureView.profileID = user.id;
	self.userName.text = user.name;
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
	self.friendListButtom.enabled = YES;
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
	self.user = nil;
	self.profilePictureView.profileID = nil;
	self.userName.text = @"";
	self.friendListButtom.enabled = NO;
}

@end

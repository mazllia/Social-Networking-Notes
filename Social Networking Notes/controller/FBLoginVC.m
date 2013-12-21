//
//  SettingTVC.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/12/2.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "FBLoginVC.h"

#import "ServerSynchronizer.h"

@interface FBLoginVC ()
@property (weak, nonatomic) IBOutlet FBProfilePictureView *fbPictureView;
@property (weak, nonatomic) IBOutlet UILabel *fbUserNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fbID;

@end

@implementation FBLoginVC

#pragma mark - FBLoginView Delegate

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
	[[[UIAlertView alloc] initWithTitle:@"FBLoginError" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Try it later!" otherButtonTitles: nil] show];
}

/**
 Login & logout determine if we still need FBCommunicator and ServerSynchronizer (ServerCommunicator)
 */
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
	self.fbPictureView.profileID = user.id;
	self.fbUserNameLabel.text = user.name;
	self.fbID.text = user.id;
	
	[ServerSynchronizer syncronizerInitWithFBGraphUser:user];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
	[ServerSynchronizer closeSynchornizer];
	
	self.fbPictureView.profileID = nil;
	self.fbUserNameLabel.text = @"Name";
	self.fbID.text = @"Facebook ID";
}

@end

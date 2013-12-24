//
//  FriendCell.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/12/3.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "FriendCell.h"
#import "Contact.h"

#import <FacebookSDK/FBRequestConnection.h>

@interface FriendCell ()
@property (weak, nonatomic) IBOutlet FBProfilePictureView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *vipView;

@end

@implementation FriendCell

- (void)setContact:(Contact *)contact
{
	if (_contact!=contact) {
		self.titleView.text = contact.nickName? contact.nickName: contact.fbName;
		self.pictureView.profileID = contact.fbUid;
		self.vipView.hidden = [contact.isVIP boolValue]? NO: YES;
		
		_contact = contact;
	}
}

@end

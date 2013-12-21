//
//  FriendCell.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/12/3.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "FriendCell.h"
#import "Contact.h"

@interface FriendCell ()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *picture;
@property (weak, nonatomic) IBOutlet UISwitch *isVIP;

@end

@implementation FriendCell

- (void)setContact:(Contact *)contact
{
	if (_contact!=contact) {
		self.name.text = contact.nickName? contact.nickName: contact.fbName;
		self.picture.profileID = contact.fbUid;
		self.isVIP.on = [contact.isVIP boolValue];
		
		_contact = contact;
	}
}

@end

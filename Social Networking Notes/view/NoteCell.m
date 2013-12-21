//
//  NoteCell.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/12/3.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "NoteCell.h"
#import "Note.h"
#import "Contact.h"

@interface NoteCell ()
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *sender;
@property (weak, nonatomic) IBOutlet UILabel *dueTime;
@property (weak, nonatomic) IBOutlet UILabel *title;

@end

@implementation NoteCell

- (void)setNote:(Note *)note
{
	if (_note!=note) {
		self.profilePictureView.profileID = note.sender.fbUid;
		self.sender.text = note.sender.nickName? note.sender.nickName: note.sender.fbName;
		self.title.text = note.title;
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MM/dd HH:ss"];
		self.dueTime.text = [dateFormatter stringFromDate:note.dueTime];

		_note = note;
	}
}

@end

//
//  EditNoteDetailVC.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/12/25.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "EditNoteDetailVC.h"
#import "Note.h"

@interface EditNoteDetailVC ()
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextField *placeText;
@property (weak, nonatomic) IBOutlet UIDatePicker *dueTimePicker;

@end

@implementation EditNoteDetailVC

- (IBAction)save:(UIBarButtonItem *)sender {
	self.note.title = self.titleText.text;
	self.note.location = self.placeText.text;
	self.note.dueTime = self.dueTimePicker.date;
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	self.titleText.text = self.note.title;
	self.placeText.text = self.note.location;
	[self.dueTimePicker setDate:self.note.dueTime animated:NO];
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

@end

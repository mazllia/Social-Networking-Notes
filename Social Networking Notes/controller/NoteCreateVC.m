//
//  NoteCreateVC.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/12/10.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "NoteCreateVC.h"
#import "ServerCommunicator.h"
#import "DatabaseManagedDocument.h"
#import "Note+Create.h"
#import "Contact+Create.h"

@interface NoteCreateVC ()
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextField *location;
@property (weak, nonatomic) IBOutlet UIDatePicker *dueTime;

@end

@implementation NoteCreateVC

- (IBAction)done:(id)sender {
	NSManagedObjectContext *context = [DatabaseManagedDocument sharedDatabase].managedObjectContext;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	NSArray *receivers = @[
						   [Contact contactWithServerInfo:@{ServerContactUID: @"44"} inManagedObjectContext:context],
						   [Contact contactWithServerInfo:@{ServerContactUID: @"44"} inManagedObjectContext:context]
						   ];
	
	Note *newNote = [Note noteWithTitle:self.titleText.text location:self.location.text dueTime:self.dueTime.date receivers:receivers media:nil inManagedObjectContext:context];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

@end

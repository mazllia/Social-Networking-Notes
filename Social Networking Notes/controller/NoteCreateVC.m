//
//  NoteCreateVC.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/12/10.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "NoteCreateVC.h"
#import "ServerCommunicator.h"
#import "ServerSynchronizer.h"
#import "DatabaseManagedDocument.h"
#import "Note+Create.h"
#import "Contact+Create.h"

#import <MediaPlayer/MediaPlayer.h>

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
						   [Contact contactWithServerInfo:@{ServerContactUID: [ServerSynchronizer sharedSynchronizer].currentUser.uid} inManagedObjectContext:context]
						   ];
	
	Note *newNote = [Note noteWithTitle:self.titleText.text location:self.location.text dueTime:self.dueTime.date receivers:receivers media:nil inManagedObjectContext:context];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)viewTabbed:(UIButton *)sender {
	NSURL *url = [NSURL fileURLWithPath:@"/Users/Mazllia/Downloads/綦光 高毅 - 怎樣(Live Version)-360p.mp4" isDirectory:NO];
	[self presentMoviePlayerViewControllerAnimated:[[MPMoviePlayerViewController alloc] initWithContentURL:url]];
}

- (IBAction)recordTabbed:(UIButton *)sender {
//	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//		[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]
//	}
//	[self presentMoviePlayerViewControllerAnimated:[[MPMoviePlayerViewController alloc] initWithContentURL:url]];
}

@end

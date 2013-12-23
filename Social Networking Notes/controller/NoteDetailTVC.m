//
//  NoteDetailTVC.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/12/3.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "NoteDetailTVC.h"

#import "Note.h"
#import "Contact.h"
#import "Multimedia+QuickLook.h"

#import "FriendCell.h"

#import "ServerSynchronizer.h" // Determine if user is sender

@interface NoteDetailTVC ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *expireLabel;

@property (weak, nonatomic) IBOutlet UIButton *archiveButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;

@property (nonatomic, strong) NSArray *receivers;
@property (nonatomic, strong) NSOperationQueue *fetchPictureQueue;
@end

@implementation NoteDetailTVC

- (IBAction)archive:(UIButton *)sender {
	self.note.archived = [NSNumber numberWithBool:![self.note.archived boolValue]];
	[self configureArchiveBottumView];
}

- (IBAction)accept:(UIButton *)sender {
	self.note.accepted = [NSNumber numberWithBool:![self.note.accepted boolValue]];
	[self configureAcceptBottumView];
}

- (IBAction)print:(id)sender {
	NSLog(@"%@", self.note.description);
}

#pragma mark - View & Class

- (void)configureArchiveBottumView
{
	if ([self.note.archived boolValue]) {
		[self.archiveButton setTitle:@"Archived" forState:UIControlStateNormal];
		[self.archiveButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
	} else {
		[self.archiveButton setTitle:@"Archive it" forState:UIControlStateNormal];
		[self.archiveButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
	}
}

- (void)configureAcceptBottumView
{
	if ([self.note.accepted boolValue]) {
		[self.archiveButton setTitle:@"Accepted" forState:UIControlStateNormal];
		[self.archiveButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
	} else {
		[self.archiveButton setTitle:@"Accept it" forState:UIControlStateNormal];
		[self.archiveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	// Set up navigation item
	if (!self.note.uid) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
		self.navigationItem.title = @"Sending";
	}
	
	// Set up header view
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEE, MMM-d HH:mm"];
	self.titleLabel.text = self.note.title;
	self.placeLabel.text = self.note.location;
	self.expireLabel.text = [dateFormatter stringFromDate:self.note.dueTime];
	
	// Set up footer view
	self.acceptButton.enabled = ([ServerSynchronizer sharedSynchronizer].currentUser==self.note.sender)? NO: YES;
	[self configureAcceptBottumView];
	[self configureArchiveBottumView];
}

- (NSOperationQueue *)fetchPictureQueue
{
	if (!_fetchPictureQueue) {
		_fetchPictureQueue = [[NSOperationQueue alloc] init];
	}
	return _fetchPictureQueue;
}

- (NSArray *)receivers
{
	if (!_receivers) {
		_receivers = [self.note.receivers allObjects];
	}
	return _receivers;
}

- (void)setNote:(Note *)note
{
	if (_note!=note) {
		self.navigationItem.title = self.note.title;
		
		_note = note;
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.note.media.count? 3: 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger numberOfRows = 0;
	switch (section) {
		case 0:
			numberOfRows = 1;
			break;
			
		case 1:
			numberOfRows = [self.note.receivers count];
			break;
			
		case 2:
			numberOfRows = [self.note.media count];
			break;
			
		default:
			break;
	}
	return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SenderCellIdentifier = @"SenderCell";
	static NSString *ReceiverCellIdentifier = @"ReceiverCell";
	static NSString *AttachmentCellIdentifier = @"AttachmentCell";
	
	UITableViewCell *cell;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	switch (indexPath.section) {
		case 0:
		{
			Contact *sender = self.note.sender;
			cell = [tableView dequeueReusableCellWithIdentifier:SenderCellIdentifier];
			
			cell.textLabel.text = sender.nickName? sender.nickName: sender.fbName;
			
			[dateFormatter setDateFormat:@"EEE, MMM-d"];
			cell.detailTextLabel.text = [dateFormatter stringFromDate:self.note.dueTime];
			
			NSString *urlStirng = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", sender.fbUid];
			NSData *picture = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStirng]];
			cell.imageView.image = [UIImage imageWithData:picture];
			break;
		}
		case 1:
		{
			Contact *receiver = self.receivers[indexPath.row];
			cell = [tableView dequeueReusableCellWithIdentifier:ReceiverCellIdentifier];

			cell.textLabel.text = receiver.nickName? receiver.nickName: receiver.fbName;

			cell.accessoryType = [self.note.accepted boolValue]? UITableViewCellAccessoryCheckmark: UITableViewCellAccessoryNone;
			
			NSString *urlStirng = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", receiver.fbUid];
			NSData *picture = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStirng]];
			cell.imageView.image = [UIImage imageWithData:picture];
			break;
		}
		case 2:
		{
			cell = [tableView dequeueReusableCellWithIdentifier:AttachmentCellIdentifier];
			cell.textLabel.text = ((Multimedia *)self.note.media[indexPath.row]).fileName;
			break;
		}
		default:
			break;
	}
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *sectionTitle;
	switch (section) {
		case 0:
			sectionTitle = @"Sender";
			break;
			
		case 1:
			sectionTitle = (self.note.receivers.count==1)? @"Receiver": @"Receivers";
			break;
			
		case 2:
			sectionTitle = (self.note.media.count==1)? @"Attachment": @"Attachments";
			break;
			
		default:
			break;
	}
	return sectionTitle;
}

#pragma mark - Table view delegate


#pragma mark - Quick look data source

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
	return self.note.media.count;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
	return self.note.media[index];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"Quick look media"]) {
		QLPreviewController *quickLookVC = [segue.destinationViewController init];
		quickLookVC.dataSource = self;
		quickLookVC.currentPreviewItemIndex = [self.tableView indexPathForSelectedRow].row;
	}
}

@end

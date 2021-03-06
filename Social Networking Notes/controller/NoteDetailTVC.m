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
#import "Multimedia+Create.h"

#import "FriendCell.h"
#import "FriendTVC.h"
#import "EditNoteDetailVC.h"

#import "DatabaseManagedDocument.h"
#import "ServerSynchronizer.h" // Determine if user is sender
#import "ServerCommunicator.h"

@interface NoteDetailTVC ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *expireLabel;

@property (weak, nonatomic) IBOutlet UIButton *archiveButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (nonatomic, readonly) NSArray *receivers;
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

- (void)saveNewlyCreatedNote
{
	
}

- (void)discardNewlyCreatedNote
{
	
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
	if (self.note.sender==[ServerSynchronizer sharedSynchronizer].currentUser)
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
//	if (!self.note.uid) {
//		self.navigationItem.rightBarButtonItem.enabled = NO;
//		self.navigationItem.title = @"Sending";
//	}
	
	if (self.note) {
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
	} else {
		self.editing = YES;
	}
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
	return [self.note.receivers allObjects];
}

- (void)setNote:(Note *)note
{
	if (_note!=note) {
		self.navigationItem.title = self.note.title;
		
		_note = note;
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
	[indexSet addIndex:2];
	[indexSet addIndex:4];
	[self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 5;
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
			
		case 3:
			numberOfRows = [self.note.media count];
			break;
			
		case 2:
		case 4:
			numberOfRows = self.editing? 1: 0;
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
	static NSString *AddReceiverCellIdentifier = @"AddReceiverCell";
	static NSString *AddAttachmentCellIdentifier = @"AddAttachmentCell";
	
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
		case 3:
		{
			Multimedia *media = self.note.media[indexPath.row];
			cell = [tableView dequeueReusableCellWithIdentifier:AttachmentCellIdentifier];
			cell.textLabel.text = media.type;
			cell.imageView.image = [media image];
			break;
		}
		case 2:
		{
			cell = [tableView dequeueReusableCellWithIdentifier:AddReceiverCellIdentifier];
			break;
		}
		case 4:
		{
			cell = [tableView dequeueReusableCellWithIdentifier:AddAttachmentCellIdentifier];
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
			
		case 3:
			switch (self.note.media.count) {
				case 0:
				case 1:
					sectionTitle = @"Attachment";
					break;
				default:
					sectionTitle = @"Attachments";
					break;
			}
			break;
			
		default:
			break;
	}
	return sectionTitle;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL result;
	switch (indexPath.section) {
		case 0:
			result = NO;
			break;
			
		default:
			result = YES;
			break;
	}
	return result;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	const NSString *AddReceiver = @"Add Receiver";
	const NSString *AddAttachment = @"Add Attachment";
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
	switch (indexPath.section) {
		case 1:
		{
			Contact *receiverNeedRemove = self.receivers[indexPath.row];
			[self.note removeReceivers:[NSSet setWithObject:receiverNeedRemove]];
			[indexSet addIndex:1];
			break;
		}
		case 3:
		{
			Multimedia *multimediaNeedRemove = self.note.media[indexPath.row];
			NSMutableArray *mediaArray = [[self.note.media array] mutableCopy];
			[mediaArray removeObject:multimediaNeedRemove];
			self.note.media = [NSOrderedSet orderedSetWithArray:mediaArray];
			[indexSet addIndex:3];
			break;
		}
		case 2:
			[self performSegueWithIdentifier:AddReceiver sender:self];
			break;
		
		case 4:
		{
			[self performSegueWithIdentifier:AddAttachment sender:self];
//			UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//			imagePicker.delegate = self;
//			
//			[self presentViewController:imagePicker animated:YES completion:nil];
			break;
		}
		default:
			break;
	}
	[self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellEditingStyle result;
	switch (indexPath.section) {
		case 1:
		case 3:
			result = UITableViewCellEditingStyleDelete;
			break;
			
		case 2:
		case 4:
			result = UITableViewCellEditingStyleInsert;
			break;
			
		default:
			result = UITableViewCellEditingStyleNone;
			break;
	}
	return result;
}

#pragma mark - Quick look data source

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
	return self.note.media.count;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
	return self.note.media[index];
}

#pragma mark - Image picker controller delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
	NSString *imageType = info[@"UIImagePickerControllerMediaType"];
	NSData *imageData;
	
	if ([imageType isEqualToString:kUTTypeImage])
		imageData = UIImageJPEGRepresentation(image, 0.2);
	
	Multimedia *newAttachment = [Multimedia multimediaWithServerInfo:@{
										   ServerMediaFileName: [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"jpeg"],
										   ServerMediaType: imageType
										   }
									data:imageData
				  inManagedObjectContext:[DatabaseManagedDocument sharedDatabase].managedObjectContext];
	
	NSMutableOrderedSet *noteMedia = [NSMutableOrderedSet orderedSetWithOrderedSet:self.note.media];
//	[self.note addMedia:[NSOrderedSet orderedSetWithObject:newAttachment]];
	[noteMedia addObject:newAttachment];
	self.note.media = noteMedia;
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"Quick look media"]) {
		QLPreviewController *quickLookVC = [segue.destinationViewController init];
		quickLookVC.dataSource = self;
		quickLookVC.currentPreviewItemIndex = [self.tableView indexPathForSelectedRow].row;
	} else if ([segue.identifier isEqualToString:@"Add Receiver"]) {
		FriendTVC *friendTVC = (FriendTVC *)segue.destinationViewController;
		friendTVC.navigationItem.hidesBackButton = YES;
		friendTVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:friendTVC action:@selector(finishSelectContacts)];
		friendTVC.navigationItem.title = @"Choose receivers";
		friendTVC.tableView.allowsMultipleSelection = YES;
		friendTVC.tableView.allowsSelection = YES;
		friendTVC.selectDelegate = self;
	} else if ([segue.identifier isEqualToString:@"Add Attachment"]) {
		UIImagePickerController *imagePicker = [(UIImagePickerController *)segue.destinationViewController init];
		imagePicker.delegate = self;
	} else if ([segue.identifier isEqualToString:@"Edit Note Detail"]) {
		EditNoteDetailVC *noteDetailVC = (EditNoteDetailVC *)segue.destinationViewController;
		noteDetailVC.note = self.note;
	}
}

- (void)friendTVC:(FriendTVC *)friendTVC didSelectContacts:(NSArray *)contacts
{
	[self.note addReceivers:[NSSet setWithArray:contacts]];
	[self.navigationController popViewControllerAnimated:YES];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end

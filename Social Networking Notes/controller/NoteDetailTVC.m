//
//  NoteDetailTVC.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/12/3.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "NoteDetailTVC.h"

#import "Note.h"
#import "Multimedia+QuickLook.h"

#import "FriendCell.h"

@interface NoteDetailTVC ()
@property (nonatomic, strong) NSArray *receivers;
@end

@implementation NoteDetailTVC

- (IBAction)print:(id)sender {
	NSLog(@"%@", self.note.description);
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
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger numberOfRows = 0;
	switch (section) {
		case 0:
		case 1:
			numberOfRows = 1;
			break;
			
		case 2:
			numberOfRows = [self.note.receivers count];
			break;
			
		case 3:
			numberOfRows = [self.note.media count];
			break;
			
		default:
			break;
	}
	return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *NoteCellIdentifier = @"NoteDetailTableCell";
	static NSString *FriendCellIdentifier = @"FriendTableCell";
	static NSString *MediaCellIdentifier = @"MediaTableCell";
	
	UITableViewCell *cell;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	switch (indexPath.section) {
		case 0:
			cell = [tableView dequeueReusableCellWithIdentifier:NoteCellIdentifier];
			
			[dateFormatter setDateFormat:@"MMM-d EEE HH:mm"];
			((UILabel *)[cell viewWithTag:1]).text = [dateFormatter stringFromDate:self.note.dueTime];
			
			((UILabel *)[cell viewWithTag:2]).text = self.note.location;
			
			[dateFormatter setDateFormat:@"MMM-d EEE HH:mm"];
			((UILabel *)[cell viewWithTag:3]).text = [@"Create at: " stringByAppendingString:[dateFormatter stringFromDate:self.note.createTime]];
			break;
			
		case 1:
			cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
			((FriendCell *)cell).contact = self.note.sender;
			break;
		case 2:
			cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
			((FriendCell *)cell).contact = self.receivers[indexPath.row];
			break;
		case 3:
			cell = [tableView dequeueReusableCellWithIdentifier:MediaCellIdentifier];
			cell.textLabel.text = ((Multimedia *)self.note.media[indexPath.row]).fileName;
		default:
			break;
	}
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *sectionTitle;
	switch (section) {
		case 1:
			sectionTitle = @"Sender";
			break;
			
		case 2:
			sectionTitle = @"Receiver";
			break;
			
		case 3:
			sectionTitle = @"Attachment";
			break;
			
		default:
			break;
	}
	return sectionTitle;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==0) {
		return 137.0;
	}
	return 70.0;
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

//
//  ServerFetcher.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/9/16.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "ServerCommunicator.h"
#import "Contact.h"
#import "Multimedia.h"
#import "Note+Create.h"
// Server
#define serverRootURL [NSURL URLWithString:@"http://people.cs.nctu.edu.tw/~chiangcw/"]

// kSenderUID, kRecieverUID, kDueTime, kTitle, kMediaFileName
#define pushURL @"create_sticky.php?"
// kNoteUID
#define pushSetMultimediaURL @"upload.php?"

// kRecieverUID
#define pullURL @"receive_sticky.php?"
// kNoteUID
#define pullInitMultimediaURL @"ask_upload_file.php?"
// kNoteUID, kMediaFileName
#define pullMultimediaURL @"UpLoad/%@/%@"

#define kSenderUID @"sender_uid"
#define kRecieverUID @"reciever_uid"
#define kNoteUID @"sticky_uid"
#define kDueTime @"alert_time"
#define kTitle @"context"
#define kMediaFileName @"file_name"

@implementation ServerCommunicator

- (NSArray *)pullNotesWith:(NSString *)contactID
{
	/// @em BUG
	// need __block?
	__block NSMutableArray *newNotes;
	
	NSOperationQueue *opQueue = [[NSOperationQueue alloc] init];
	[opQueue addOperationWithBlock:^{
		for (NSDictionary *noteInfo in [self serverGetNotesForUser:contactID]) {
			Note *tmpNote = [[Note alloc] initWithRecievers:@[contactID]
														uid:noteInfo[kNoteUID]
													  title:noteInfo[kTitle]
													dueTime:noteInfo[kDueTime]
												   location:@"<#string#>"
												 multimedia:[self serverGetMediaForUser:contactID]];
			[newNotes addObject:tmpNote];
		}
	}];
	NSArray *notes = [NSJSONSerialization JSONObjectWithData:JSONData
													 options:NSJSONReadingMutableContainers
													   error:&err];
	
}

- (BOOL)pushNotes:(Note *)note toRecivers:(NSArray *)recievers
{
	
	for (Contact *contact in recievers) {
		<#statements#>
	}
}

#pragma mark -

#pragma mark - Server Internal Internet API
// Warning: All server internal internet API shall be executed in background thread
// ServerCommunicator API should return ASAP

/**
 Push(1)
 @return NoteUID
 @em BUG
 Need decision: how the note uid passes
 */
- (NSString *)serverCreateWithSender:(NSString *)senderUID
							reciever:(NSString *)recieverUID
							 dueTime:(NSDate *)dueTime
							   title:(NSString *)title
					   mediaFileName:(NSString *)mediaFileName
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@=%@&%@=%@&%@=%@&%@=%@&%@=%@", pushURL, kSenderUID, senderUID, kRecieverUID, recieverUID, kDueTime, dueTime, kTitle, title, kMediaFileName, mediaFileName] relativeToURL:serverRootURL];
	[NSURLRequest requestWithURL:url];
	/// @em bug
	// Get the NoteUID
}

/**
 Push(2)
 @em BUG
 Need confirm: is the media transfer by POST? JSON containing array?
 */
- (void)serverUploadMediaToNote:(NSString *)noteUID
						  media:(NSArray *)Multimedia
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@=%@", pushSetMultimediaURL, kNoteUID, noteUID] relativeToURL:serverRootURL];
	[NSURLRequest requestWithURL:url];
	/// @em bug
	// Upload the media
}

/**
 Pull(1)
 @return array of nsdictionary
 */
#define kJSONArrayName sticky_attribute_list
- (NSArray *)serverGetNotesForUser:(NSString *)userID
{
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@=%@", pullURL, kRecieverUID, userID] relativeToURL:serverRootURL];
	NSData *JSONData = [NSData dataWithContentsOfURL:url];
	NSError *err;
	NSArray *notes = [NSJSONSerialization JSONObjectWithData:JSONData
													 options:0
													   error:&err];
	if (err) {
		NSLog(@"%@", [err localizedDescription]);
	}
	
	return notes;
}

/**
 Pull(2)
 @return array of multimedia
 */
- (NSArray *)serverGetMediaForUser:(NSString *)userID
{
	
}

@end

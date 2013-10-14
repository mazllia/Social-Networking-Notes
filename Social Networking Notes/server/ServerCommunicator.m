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
- (NSString *)serverCreateWithSender:(NSString *)sender_uid
                       receiver_list:(NSMutableArray *)receiver_uid_list
                            sendTime:(NSString *)send_time
                             dueTime:(NSString *)alert_time
                       mediaFileName:(NSMutableArray *) file_name_list
                             context:(NSString *)context
                            location:(NSString*) location{
    //handle receiver_uid_list data
    NSMutableArray *receiver_data = [[NSMutableArray alloc] init];
    for(NSString * receiver in receiver_uid_list){
        NSMutableDictionary *r =[[NSMutableDictionary alloc] init];
        [r setValue:receiver forKey:@"receiver_uid" ];
        [receiver_data addObject:r];
    }
    //handle file_name_list data
    NSMutableArray *file_name_data = [[NSMutableArray alloc] init];
    for(NSString * file_name in file_name_list){
        NSMutableDictionary *f =[[NSMutableDictionary alloc] init];
        [f setValue:file_name forKey:@"file_name" ];
        [file_name_data addObject:f];
    }
    //tranform to json data
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:sender_uid forKey:@"sender_uid" ];
    [data setValue:receiver_data forKey:@"receiver_uid_list" ];
    [data setValue:send_time forKey:@"send_time"];
    [data setValue:alert_time forKey:@"alert_time" ];
    [data setValue:file_name_data forKey:@"file_name_list" ];
    [data setValue:context forKey:@"context" ];
    [data setValue:location forKey:@"location" ];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *str =[NSString stringWithFormat:@"http://people.cs.nctu.edu.tw/~chiangcw/create_sticky.php?json_note=%@",jsonString];
    NSString* str2 =[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:str2];
    
    //開始與server 連線
    NSString *response;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval: 3.0]; // Will timeout after 3 seconds
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (data != nil && error == nil)
                               {
                                   NSString *sourceHTML = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   response = [NSString stringWithFormat:@"%@",sourceHTML];
                               }
                               else
                               {
                                   NSLog(@"error!");
                               }
                               
    }];
    
    return response;
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

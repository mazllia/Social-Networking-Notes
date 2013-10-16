//
//  ServerFetcher.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/9/16.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Key for JSON Array/Dictionary
 1. Note
 2. Multimedia
 3. Contact
 */
#define kNoteUID @"sticky_uid"
#define kSenderUID @"sender_uid"
#define KRecieverUIDList @"receiver_uid_list"
#define kRecieverUID @"reciever_uid"
#define kDueTime @"alert_time"
#define kCreateTime @""
#define kTitle @"context"
#define kLocation @"location"
#define kAccepted @""
#define kRead @""
#define kArchive @""

#define kMediaType @""
#define kMediaFileName @"file_name"

#define kContactUID @""
#define kFbAccountIdentifier @""
#define kIsVIP @""
#define kNickName @""

#define kRecievingJSONArrayName @"json_note"
#define kSendingJSONArrayName @"sticky_attribute_list"

@interface ServerCommunicator : NSObject

/**
 Get new notes from server.
 @return array of notes
 */
- (NSArray *)lastestNotes;

/**
 Create new notes to server.
 @param recievers: array of "Contact uid"
 @return NoteUID; nil when failed.
 */
- (NSString *)pushNotes:(NSArray *)notes toRecivers:(NSArray *)recievers;

@end

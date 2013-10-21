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
#define ServerNoteUID @"sticky_uid"
#define ServerNoteSenderUID @"sender_uid"
#define ServerNoteRecieverUIDList @"receiver_uid_list"
#define ServerNoteRecieverUID @"reciever_uid"
#define ServerNoteDueTime @"alert_time"
#define ServerNoteCreateTime @""
#define ServerNoteTitle @"context"
#define ServerNoteLocation @"location"
#define ServerNoteAccepted @""
#define ServerNoteRead @""
#define ServerNoteArchive @""

#define ServerMediaType @""
#define ServerMediaFileName @"file_name"

#define ServerContactUID @""
#define ServerContactFbAccountIdentifier @""
#define ServerContactIsVIP @""
#define ServerContactNickName @""

#define ServerJSONArrayNameRecieving @"json_note"
#define ServerJSONArrayNameSending @"sticky_attribute_list"

@interface ServerCommunicator : NSObject

/**
 Get new notes from server.
 @return array of notes
 */
+ (NSArray *)lastestNotes;

/**
 Create new notes to server.
 @param receivers array of "Contact uid"
 @return NoteUID; nil when failed.
 */
+ (NSString *)pushNotes:(NSArray *)notes toReceivers:(NSArray *)receivers;

@end

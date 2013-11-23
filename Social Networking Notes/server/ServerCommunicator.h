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
#define ServerNoteUserUID @"user_uid"
#define ServerNoteUID @"sticky_uid"
#define ServerNoteSenderUID @"sender_uid"
#define ServerNoteReceiverList @"receiver_list"
#define ServerNoteReceiverUID @"receiver_uid"
#define ServerNoteDueTime @"alert_time"
#define ServerNoteCreateTime @"send_time"
#define ServerNoteTitle @"context"
#define ServerNoteLocation @"location"
#define ServerNoteAccepted @"accepted"
#define ServerNoteRead @"read"
// Wrong spelling
#define ServerNoteArchive @"archieved"

#define ServerMediaType @"file_type"
// rename is better
#define ServerMediaFileList @"file_name_list"
#define ServerMediaFileName @"file_name"
#define ServerMediaSync @""

#define ServerContactUID @"contact_uid"
#define ServerContactFbAccountIdentifier @"facebook_uid"
#define ServerContactIsVIP @"isvip"
#define ServerContactNickName @"nick_name"

#define ServerJSONArrayNameRecieving @"json_note"
#define ServerJSONArrayNameSending @"sticky_attribute_list"

typedef enum {
    ServerActionPush,
    ServerActionPull
} ServerAction;

/**
 Let delegate to handle sync status.
 */
@protocol ServerCommunicatorDelegate <NSObject>
@required
/**
 @param syncedNoteDictionaries Dictionaries with constant @e ServerNote* key and its value pairs
 */
- (void)serverCommunicatorNotesSynced:(NSArray *)syncedNoteDictionaries fromAction:(ServerAction)action;
/**
 @param syncedContactDictionaries Dictionaries with constant @e ServerContact* key and its value pairs
 */
- (void)serverCommunicatorContactSynced:(NSArray *)syncedContactDictionaries fromAction:(ServerAction)action;
@end

@class Note;

@interface ServerCommunicator : NSObject<NSURLConnectionDelegate,NSURLSessionDownloadDelegate>

- (instancetype)initWithDelegate:(id<ServerCommunicatorDelegate>)delegate;

/**
 當使用者第一次使用app時，使用這api跟server索取ContactUID (假如使用的facebookUID 已經存在，則回傳該 facebookUID 綁定的ContactUID。
 @return ContactUID
 */
- (NSString *)registerUserAccount;

/**
 Tell the server user's all friends and get our users, which is a subset of user's all friends. Evoking @e serverCommunicatorContactSynced method.
 @param fbFriends Array of Facebook uid @e NSString
 @return NO if server is unavailable
 */
- (BOOL)getAvailableUsersFromFBFriends:(NSArray *)fbFriends;

/**
 Accept un-synced @e NSManagedObject classes, including creation and modification, and upload it to our server. Evoking @e serverCommunicatorNotesSynced and @e serverCommunicatorContactsSynced method.
 @return NO if server is unavailable
 */
- (BOOL)pushNotes:(NSArray *)notes contacts:(NSArray *)contacts;

/**
 Get all notes, from the purpose of user's devices sync and user friend's note sending. Evoking @e serverCommunicatorNotesSynced method.
 @return NO if server is unavailable
 */
- (BOOL)getLastestNotes;

@end

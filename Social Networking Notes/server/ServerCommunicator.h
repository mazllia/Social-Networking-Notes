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
#define ServerNoteReceiverUIDList @"receiver_uid_list"
#define ServerNoteReceiverUID @"reciever_uid"
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

@class Note;

@interface ServerCommunicator : NSObject<NSURLConnectionDelegate,NSURLSessionDownloadDelegate>

/*
 use for get information from uploading file
 */
@property (nonatomic,strong) NSMutableData *receivedData;

/*
 use for api downloadFile:fileName:fileSaveProsition:
 */
@property (nonatomic,strong) NSURL *saveProsition;

#pragma mark - Note

- (BOOL)modifySendedNote:(Note *)note noteUID:(NSString *)noteUID toReceivers:(NSArray *)receivers;

/**
 Create new notes to server.
 @param receivers array of "Contact uid"
 @return NoteUID; nil when failed.
 */
- (NSString *)pushNotes:(Note *)note toReceivers:(NSArray *)receivers;

/*
 Get new notes from server.
 @return array of notes
 */
- (NSArray *)serverGetNotesForUser:(NSString *)userID;

-(NSString *) checkNoteState:(NSString *)noteUID receiverUID:(NSString *)receiverUID;

- (BOOL) updateNoteStateToRead:(NSString *)noteUID userUID:(NSString *)userUID;

#pragma mark - Contact

- (NSArray *)getVipList:(NSString *)userUID;

- (BOOL) setSomenoeToVip:(NSString *)userUID someoneYouLove:(NSString *)LoveUID;

- (BOOL) cancelSomeoneVip:(NSString *)userUID someoneYouLoveBefore:(NSString *)LoveUID;

#pragma mark - Files

/*
 upload note's file to server.
 */
- (void)uploadFile:(NSString *)stickyUID fileData:(NSData *)paramData filePath:(NSString *)path fileName:(NSString *)Name;

/*
 dwonload note's file to server.
 */
- (void) downloadFile:(NSString *)stickyUID fileName:(NSString *)fileName fileSaveProsition:(NSURL *)saveProsition;

@end

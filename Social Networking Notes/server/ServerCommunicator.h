//
//  ServerFetcher.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/9/16.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Note;

@interface ServerCommunicator : NSObject<NSURLConnectionDelegate,NSURLSessionDownloadDelegate>

/**
 Get new notes from server.
 You should not call this function in mainThread
 @return array of notes
 */
- (NSArray *)pullNotesWith:(NSString *)contactID;

- (BOOL)modifySendedNote:(Note *)note noteUID:(NSString *)noteUID toRecivers:(NSArray *)recivers
/**
 Create new notes to server.
 You should not call this function in mainThread
 @param recievers: array of "Contact uid"
 @return NoteUID; nil when failed.
 */
- (NSString *)pushNotes:(Note *)note toRecivers:(NSArray *)recievers;
/*
 receive note from server
*/
- (NSArray *)serverGetNotesForUser:(NSString *)userID

/*
 upload note's file to server.
*/
- (void)uploadFile:(NSString *)stickyUID fileData:(NSData *)paramData filePath:(NSString *)path fileName:(NSString *)Name
/*
 dwonload note's file to server.
*/
- (void) downloadFile:(NSString *)stickyUID fileName:(NSString *)fileName fileSaveProsition:(NSURL *)SaveProsition

-(NSString *) checkNoteState:(NSString *)noteUID receiverUID:(NSString *)receiverUID

- (BOOL) updateNoteStateToRead:(NSString *)noteUID userUID:(NSString *)userUID

- (BOOL) setSomenoeToVip:(NSString *)userUID someoneYouLove:(NSString *)LoveUID

- (BOOL) cancelSomeoneVip:(NSString *)userUID someoneYouLoveBefore:(NSString *)LoveUID
/*
 use for get information from uploading file
*/
@property (nonatomic,strong) NSMutableData *receivedData;

/*
 use for api downloadFile:fileName:fileSaveProsition:
 
*/
@property (nonatomic,strong) NSMutableData *SaveProsition;

@end

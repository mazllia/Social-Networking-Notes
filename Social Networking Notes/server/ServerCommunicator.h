//
//  ServerFetcher.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/9/16.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Note;

@interface ServerCommunicator : NSObject

/**
 Get new notes from server.
 You should not call this function in mainThread
 @return array of notes
 */
- (NSArray *)pullNotesWith:(NSString *)contactID;

/**
 Create new notes to server.
 You should not call this function in mainThread
 @param recievers: array of "Contact uid"
 @return NoteUID; nil when failed.
 */
- (NSString *)pushNotes:(Note *)note toRecivers:(NSArray *)recievers;
/*
 
*/
- (NSString *)serverCreateWithSender:(NSString *)sender_uid
                            receiver_list:(NSMutableArray *)receiver_uid_list
                            sendTime:(NSString *)send_time
                             dueTime:(NSString *)alert_time
                       mediaFileName:(NSMutableArray *) file_name_list
                             context:(NSString *)context
                            location:(NSString*) location;

@end
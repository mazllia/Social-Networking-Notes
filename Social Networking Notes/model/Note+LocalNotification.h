//
//  Note+LocalNotification.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/12/24.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "Note.h"

/**
 There are 4 note status
 @param NoteLocalNotificationNoteType1
 Newly created send-to-self note: currentUser==sender==receiver && !uid
 @param NoteLocalNotificationNoteType2 Synced/Modified send-to-self note: currentUser==sender==receiver && uid
 @param NoteLocalNotificationNoteType3
 Synced/Modified other-to-self note: currentUser!=sender
 */
typedef enum {
	NoteLocalNotificationNoteType1 = 1,
	NoteLocalNotificationNoteType2 = 1<<1,
	NoteLocalNotificationNoteType3 = 1<<2,
} NoteLocalNotificationNoteType;

@interface Note (LocalNotification)

/**
 Insert or replace corresponding @e UILocalNotification in the @e UIApplication singleton. In another word, make sure there is only one @e UILocalNotification of this note in this application. The property @b userInfo of fired @e UILocalNotification always contains 2 key-value pairs. One of the pairs key is: @b ServerNoteUID if note has property @b uid; @b ServerNoteCreateTime otherwise. Another of the pairs key is @b NoteType with value @e NoteLocalNotificationNoteType
 @note This method use @e UIKit and thus can only executed in @b main thread.
 */
- (void)fireLocalNotification;

@end

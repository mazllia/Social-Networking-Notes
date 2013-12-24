//
//  Note+LocalNotification.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/12/24.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "Note+LocalNotification.h"

#import "ServerCommunicator.h"	// For parsing dictionary purpose
#import "ServerSynchronizer.h"	// For current user

@implementation Note (LocalNotification)

- (void)fireLocalNotification
{
	// Block non-main thread method call
	if ([NSOperationQueue currentQueue] != [NSOperationQueue mainQueue])
		[[NSException exceptionWithName:@"Note+Create" reason:@"fireLocalNotification is called in non-main thread" userInfo:nil] raise];
	
	// Determine note type
	BOOL amISender = [self.receivers containsObject:[ServerSynchronizer sharedSynchronizer].currentUser];
	BOOL isNewlyCreate = self.uid? NO: YES;
	
	NoteLocalNotificationNoteType noteTypeValue = amISender?
	(isNewlyCreate? NoteLocalNotificationNoteType1: NoteLocalNotificationNoteType2):
	NoteLocalNotificationNoteType3;
	NSNumber *noteType = [NSNumber numberWithInt:noteTypeValue];
	
	// Set up userInfo dictionary
	static NSString *NoteTypeKey =  @"NoteType";
	NSMutableDictionary *notificationUserInfo = isNewlyCreate? [@{ServerNoteCreateTime: self.createTime} mutableCopy]: [@{ServerNoteUID: self.uid} mutableCopy];
	[notificationUserInfo setValue:noteType forKey:NoteTypeKey];
	
	/*
	 Erase old UILocalNotification of this Note from UIApplication. To erase old UINotification fired by self:
	 1. #2 search for #1 & #2
	 2. #3 search for #3
	 
	 @note Newly created note should be modified before sync with server. This should be block by view controllers
	 */
	UIApplication *app = [UIApplication sharedApplication];
	switch (noteTypeValue) {
		case NoteLocalNotificationNoteType2:
		{
			[app.scheduledLocalNotifications enumerateObjectsUsingBlock:^(UILocalNotification *obj, NSUInteger idx, BOOL *stop) {
				NoteLocalNotificationNoteType notificationNoteType = [(NSNumber *)obj.userInfo[NoteTypeKey] intValue];
				BOOL isTargetType1 = notificationNoteType & NoteLocalNotificationNoteType1;
				BOOL isTargetType2 = notificationNoteType & NoteLocalNotificationNoteType2;
				BOOL shouldDelete = (isTargetType1 & [obj.userInfo[ServerNoteCreateTime] isEqualToDate:self.createTime]) || (isTargetType2 & [obj.userInfo[ServerNoteUID] isEqualToString:self.uid]);
				if (shouldDelete) {
					[app cancelLocalNotification:obj];
					*stop = YES;
				}
			}];
			break;
		}
		case NoteLocalNotificationNoteType3:
		{
			[app.scheduledLocalNotifications enumerateObjectsUsingBlock:^(UILocalNotification *obj, NSUInteger idx, BOOL *stop) {
				NoteLocalNotificationNoteType notificationNoteType = [(NSNumber *)obj.userInfo[NoteTypeKey] intValue];
				BOOL isTargetType = notificationNoteType & NoteLocalNotificationNoteType3;
				BOOL shouldDelete = isTargetType & [obj.userInfo[ServerNoteUID] isEqualToString:self.uid];
				if (shouldDelete) {
					[app cancelLocalNotification:obj];
					*stop = YES;
				}
			}];
			break;
		}
		case NoteLocalNotificationNoteType1:
		default:
			break;
	}
	
	static NSString *NotificationAlertActionString = @"Detail";
	/*
	 Block earlier fire date then
	 Configure new UILocalNotification and insert into UIApplication
	 */
	NSDate *now = [NSDate date];
	if ([now earlierDate:self.dueTime]==now) {
		UILocalNotification *notification = [[UILocalNotification alloc] init];
		notification.fireDate = self.dueTime;
		notification.alertBody = [NSString stringWithFormat:@"%@ %@.", self.title, self.location];
		notification.alertAction = NotificationAlertActionString;
		notification.applicationIconBadgeNumber = 1;
		notification.userInfo = notificationUserInfo;
		
		[app scheduleLocalNotification:notification];
	}
}


@end

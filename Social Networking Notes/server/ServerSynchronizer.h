//
//  ServerSynchronizer.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/11/16.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ServerSynchronizerNotificationContactSynced @"ServerSynchronizerNotificationContactSynced"
#define ServerSynchronizerNotificationNoteSynced @"ServerSynchronizerNotificationNoteSynced"

@class Contact;
/**
 A singleton class scan through local Core Data and sync with cloud server, providing manual and automatic sync.
 @discussion Only use this class after user account is initialized.
 */
@interface ServerSynchronizer : NSObject

/**
 Time interval in second saying the frequency of automatic sync. Default value is 300 (5 minutes).
 */
@property (nonatomic) NSTimeInterval autoSyncTimeInterval;

/**
 Indicate if @e ServerSynchronizer is now currently busy with @e ServerCommunicator
 @discussion [BUG] nonatomic or atomic? It may be modified
 */
@property (nonatomic, readonly) BOOL syncing;

/**
 Current login user of this device as a Contact instance. This performs the same method: @b registerUserAccount in @e ServerCommunicator when first use.
 */
@property (nonatomic, strong, readonly) Contact *currentUser;

/**
 Manually sync all data.
 */
- (void)sync;

// Singelton

/**
 Use this class method to reach the singleton synchronizer.
 @return nil if ServerSynchronizer isn't initilized by @b syncronizerInitWithFBGraphUser:
 */
+ (instancetype)sharedSynchronizer;
+ (id)allocWithZone:(struct _NSZone *)zone;

/**
 To initilize the singleton class.
 */
+ (instancetype)syncronizerInitWithFBGraphUser:(id <FBGraphUser>) user;
/**
 Set shared object to nil. Usually used when user logout.
 */
+ (void)closeSynchornizer;

@end

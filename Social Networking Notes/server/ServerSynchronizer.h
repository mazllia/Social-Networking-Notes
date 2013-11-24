//
//  ServerSynchronizer.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/11/16.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

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
 Current login user of this device as a Contact instance
 */
@property (nonatomic, strong, readonly) Contact *currentUser;
/**
 Manually sync all data.
 */
- (void)sync;

/**
 Use this class method to reach the singleton synchronizer
 */
+ (instancetype)sharedSynchronizer;
+ (id)allocWithZone:(struct _NSZone *)zone;

@end

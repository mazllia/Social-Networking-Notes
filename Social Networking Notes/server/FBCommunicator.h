//
//  FBCommunicator.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/11/20.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Singleton class communicates to Facebook SDK and cache the essential objects. This class perform in synchronous way.
 */
@interface FBCommunicator : NSObject

/**
 Indicate if @e FBCommunicator is now currently busy with Facebook SDK
 @discussion [BUG] nonatomic or atomic? It may be modified
 */
@property (nonatomic, readonly, getter = isSyncing) BOOL syncing;
/**
 Array of @e id<FBGraphUser> containing all info from Facebook Graph API @b me/friends.
 */
@property (nonatomic, strong, readonly) NSArray *friendsInfo;
/**
 The current user depending on current login session.
 @param me If it is nil, evoke query to Facebook Graph APi @b me. You get nil while it is busy querying!
 */
@property (nonatomic, strong) id<FBGraphUser> me;

/**
 Manually update lastest available friends, who are currently register to use our APP, from Facebook Graph API.
 */
- (void)fetchLastestFriends;

- (id)init;

/**
 Use this class method to reach the singleton
 */
+ (instancetype)sharedCommunicator;
+ (id)allocWithZone:(struct _NSZone *)zone;

@end

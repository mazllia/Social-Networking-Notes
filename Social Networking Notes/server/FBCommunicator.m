//
//  FBCommunicator.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/11/20.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "FBCommunicator.h"

@interface FBCommunicator ()

// Overwrite properties to have setter
@property (readwrite) BOOL syncing;
@property (readwrite) NSArray *friendsInfo;

@property (nonatomic) BOOL syncingMe;

@end

@implementation FBCommunicator
static id sharedFBCommunicator = nil;

#pragma mark - Public APIs

- (id)init
{
	self = [super init];
	if (self) {
		[self fetchLastestFriends];
	}
	return self;
}

- (void)fetchLastestFriends
{
	if ([FBSession activeSession] && !self.syncing) {
		self.syncing = YES;
		
		[FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphObject> result, NSError *error) {
			if (error) {
				[NSException exceptionWithName:@"FBCommunicator fetchLatestFriends FBRequestConnection error" reason:error.localizedDescription userInfo:nil];
			}
			self.friendsInfo = [result objectForKey:@"data"];
			self.syncing = NO;
		}];
	}
}

- (NSArray *)friendsInfo
{
	if (!_friendsInfo) {
		[self fetchLastestFriends];
	}
	return _friendsInfo;
}

- (NSArray *)friendsUID
{
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.friendsInfo.count];
	for (id<FBGraphUser> graphUser in self.friendsInfo) {
		[result addObject:[graphUser id]];
	}
	return [result copy];
}

- (id<FBGraphUser>)me
{
	if (!_me) {
		[self fetchMe];
	}
	return _me;
}

#pragma mark - Private APIs

- (void)fetchMe
{
	if ([FBSession activeSession] && !self.syncingMe) {
		self.syncingMe = YES;
		
		[FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> result, NSError *error) {
			if (error) {
				[NSException exceptionWithName:@"FBCommunicator fetchMe FBRequestConnection error" reason:error.localizedDescription userInfo:nil];
			}
			self.me = result;
			self.syncingMe = NO;
		}];
	}
}

#pragma mark - singleton

+ (instancetype)sharedCommunicator
{
	if (!sharedFBCommunicator) {
		sharedFBCommunicator = [[super allocWithZone:nil] init];
	}
	return sharedFBCommunicator;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
	return [self sharedCommunicator];
}

@end

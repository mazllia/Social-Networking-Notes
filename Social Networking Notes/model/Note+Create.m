//
//  Note+Create.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/1.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "Note+Create.h"
#import "Contact.h"
#import "ServerCommunicator.h"

@implementation Note (Create)

+ (instancetype)noteWithRecievers:(NSArray *)reciever
							  uid:(NSString *)uid
							title:(NSString *)title
						  dueTime:(NSDate *)dueTime
						 location:(NSString *)location
					   multimedia:(NSArray *)multimedia
{
	return [[Note alloc] initWithRecievers:reciever uid:uid title:title dueTime:dueTime location:location multimedia:multimedia];
}

// Desginate initializer
- (instancetype)initWithRecievers:(NSArray *)reciever
							  uid:(NSString *)uid
							title:(NSString *)title
						  dueTime:(NSDate *)dueTime
						 location:(NSString *)location
					   multimedia:(NSArray *)multimedia
{
	self.uid = uid;
	self.createTime = [NSDate date];
	self.title = title;
	self.dueTime = dueTime;
	self.location = location;
	[self addRecievers:[NSSet setWithArray:reciever]];
	[self addMedia:[NSOrderedSet orderedSetWithArray:multimedia]];
	
	NSOperationQueue *serverOperation = [[NSOperationQueue alloc] init];
	/// @em BUG
	// Not sure if here needs the "__block"
	__block ServerCommunicator *server = [[ServerCommunicator alloc] init];
	[serverOperation addOperationWithBlock:^{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		self.uid = [server pushNotes:self toRecivers:reciever];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}];
	
	return self;
}

+ (instancetype)noteWithRecievers:(NSArray *)reciever
							  uid:(NSString *)uid
							title:(NSString *)title
						  dueTime:(NSDate *)dueTime
						 location:(NSString *)location
{
	return [[Note alloc] initWithRecievers:reciever uid:uid title:title dueTime:dueTime location:location];
}

- (instancetype)initWithRecievers:(NSArray *)reciever
							  uid:(NSString *)uid
							title:(NSString *)title
						  dueTime:(NSDate *)dueTime
						 location:(NSString *)location
{
	return [self initWithRecievers:reciever uid:uid title:title dueTime:dueTime location:location multimedia:nil];
}

@end

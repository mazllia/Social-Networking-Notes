//
//  Note+Create.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/1.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "Note.h"

@interface Note (Create)

+ (instancetype)noteWithRecievers:(NSArray *)reciever
					uid:(NSString *)uid
				  title:(NSString *)title
				dueTime:(NSDate *)dueTime
			   location:(NSString *)location
			 multimedia:(NSArray *)multimedia;

/// Designate initializer
- (instancetype)initWithRecievers:(NSArray *)reciever
					  uid:(NSString *)uid
				   title:(NSString *)title
				  dueTime:(NSDate *)dueTime
				 location:(NSString *)location
			  multimedia:(NSArray *)multimedia;

+ (instancetype)noteWithRecievers:(NSArray *)reciever
					uid:(NSString *)uid
				  title:(NSString *)title
				dueTime:(NSDate *)dueTime
			   location:(NSString *)location;

- (instancetype)initWithRecievers:(NSArray *)reciever
					  uid:(NSString *)uid
					title:(NSString *)title
				  dueTime:(NSDate *)dueTime
				 location:(NSString *)location;

@end

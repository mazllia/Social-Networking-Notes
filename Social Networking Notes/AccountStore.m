//
//  Account.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/2.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "AccountStore.h"

@implementation AccountStore
static AccountStore *sharedAccount = nil;

#pragma mark - singleton

+ (id)sharedAccount
{
	if (!sharedAccount) {
		sharedAccount = [[super allocWithZone:NULL] init];
	}
	return self;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
	return [self sharedAccount];
}

@end

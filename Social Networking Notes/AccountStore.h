//
//  Account.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/2.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import <Accounts/Accounts.h>

@interface AccountStore : ACAccountStore

+ (id)allocWithZone:(NSZone *)zone;
+ (id)sharedAccount;

@end

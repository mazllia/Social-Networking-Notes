//
//  TestVC.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/5.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "TestVC.h"
#import "AccountStore.h"

@import Social;

@interface TestVC ()
- (IBAction)buttonTapped;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) AccountStore *accountStore;

@end

@implementation TestVC

- (AccountStore *)accountStore
{
	if (!_accountStore) {
		_accountStore = [AccountStore sharedAccount];
	}
	return _accountStore;
}

- (IBAction)buttonTapped {
	ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
	
	NSDictionary *facebookDictionary = @{
		ACFacebookAppIdKey: @"174186899453258",
//		ACFacebookPermissionsKey: @"email"
	};
	[self.accountStore requestAccessToAccountsWithType:accountType options:facebookDictionary completion:^(BOOL granted, NSError *error) {
		NSLog(@"%@", [error localizedDescription]);
		if (granted) {
			NSLog(@"1");
			NSArray *array = [self.accountStore accountsWithAccountType:accountType];
		} else {
			NSLog(@"2");
		}
	}];
}

@end

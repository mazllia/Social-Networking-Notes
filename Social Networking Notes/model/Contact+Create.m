//
//  Contact+Create.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/9.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "Contact+Create.h"
#import "NSObject+ClassName.h"

#import "FBCommunicator.h"
#import "ServerCommunicator.h"	// For parsing dictionary purpose

@implementation Contact (Create)

+ (instancetype)contactWithServerInfo:(NSDictionary *)contactDictionary
			   inManagedObjectContext:(NSManagedObjectContext *)context
{
	id contact;
	
	/*
	 Perform fetch from core data
	 */
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self className]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uid = %@", contactDictionary[ServerContactUID]]];
	
	NSError *err;
	NSArray *matches = [context executeFetchRequest:fetchRequest error:&err];

	/*
	 Check if fetch result valid & perform actions
	 1. Invalid result
	 2. 0 match: not existed in data base, create
	 * Foolproof for paramter: noteDictionary[ServerNoteUID]
	 3. 1 match: query only
	 4. 1 match: modification
	 */
	if (!matches || [matches count]>1) {
		[[NSException exceptionWithName:@"Contact(Create) Fetch Error" reason:[err localizedDescription] userInfo:nil] raise];
	} else if ([matches count]==0 && contactDictionary[ServerContactUID]) {
		contact = [[NSEntityDescription insertNewObjectForEntityForName:[self className] inManagedObjectContext:context]
				   initWithServerInfo:contactDictionary];
	} else if ([contactDictionary count]==1) {
		contact = [matches lastObject];
	} else {
		contact = [[matches lastObject] initWithServerInfo:contactDictionary];
	}
	
	return contact;
}

#pragma mark - Private APIs

/**
 Parse the server info-dictionary (the relationship will be handle in Note+Create).
 */
- (instancetype)initWithServerInfo:(NSDictionary *)contactDictionary
{
	// Deal with properties
	self.uid = contactDictionary[ServerContactUID];
	self.isVIP = contactDictionary[ServerContactIsVIP]? contactDictionary[ServerContactIsVIP]: self.isVIP;
	self.nickName = contactDictionary[ServerContactNickName]? contactDictionary[ServerContactNickName]: self.nickName;
	
	// Deal with accounts
	// 1) If I am the contact
	if ([[FBCommunicator sharedCommunicator].me.id isEqualToString:contactDictionary[ServerContactFbAccountIdentifier]]) {
		self.fbAccount = [FBCommunicator sharedCommunicator].me;
		return self;
	}
	// 2) If one of friends is the contact
	for (id<FBGraphUser> contact in [FBCommunicator sharedCommunicator].friendsInfo) {
		NSString *contactUID = contactDictionary[ServerContactFbAccountIdentifier];
		if ([[contact id] isEqualToString:contactUID]) {
			self.fbAccount = contact;
			break;
		}
	}
	
	return self;
}

@end

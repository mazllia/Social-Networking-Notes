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
	 Perform fetch from disk
	 */
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self className]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uid = %@", contactDictionary[ServerContactUID]]];
	
	NSError *err;
	NSArray *matches = [context executeFetchRequest:fetchRequest error:&err];

	/*
	 Check if fetch result valid & perform actions
	 1. Invalid
	 2. Not existed in data base
	 3. Valid
	 */
	if (!matches || [matches count]>1) {
		[[NSException exceptionWithName:@"Contact(Create) Fetch Error" reason:[err localizedDescription] userInfo:nil] raise];
	} else if ([matches count]==0) {
		contact = [[self alloc] initWithServerInfo:contactDictionary className:[self className] inManagedObjectContext:context];
	} else {
		contact = [matches lastObject];
	}
	
	return contact;
}

#pragma mark - Private APIs

/**
 Parse and save the server info-dictionary (the relationship will be handle in Note+Create).
 @param className
 Because the instance object class description may changed, pass from class method to identify entity name
 */
- (instancetype)initWithServerInfo:(NSDictionary *)contactDictionary
						 className:(NSString *)className
			inManagedObjectContext:(NSManagedObjectContext *)context
{
	// Insert self into data base
	self = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:context];
	
	// Deal with properties
	self.uid = contactDictionary[ServerContactUID];
	self.isVIP = [NSNumber numberWithBool:(BOOL)contactDictionary[ServerContactIsVIP]];
	self.nickName = contactDictionary[ServerContactNickName];
	
	// Deal with accounts
	// 1) If I am the contact
	if ([[[FBCommunicator sharedCommunicator].me id] isEqualToString:contactDictionary[ServerContactFbAccountIdentifier]]) {
		self.fbAccount = contactDictionary[ServerContactFbAccountIdentifier];
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

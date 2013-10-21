//
//  Note+Create.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/1.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "Note+Create.h"
#import "NSObject+ClassName.h"

#import "ServerCommunicator.h"	// For parsing dictionary purpose

@implementation Note (Create)

+ (instancetype)noteWithServerInfo:(NSDictionary *)noteDictionary
							sender:(Contact *)sender
						 receivers:(NSArray *)receivers
							 media:(NSOrderedSet *)media
			inManagedObjectContext:(NSManagedObjectContext *)context
{
	id note;
	
	/*
	 Perform fetch from disk
	 */
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self className]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uid = %@", noteDictionary[ServerContactUID]]];
	
	NSError *err;
	NSArray *matches = [context executeFetchRequest:fetchRequest error:&err];
	
	/*
	 Check if fetch result valid & perform actions
	 1. Invalid
	 2. Not existed in data base
	 3. Valid
	 */
	if (!matches || [matches count]>1) {
		[[NSException exceptionWithName:@"Note(Create) Fetch Error" reason:[err localizedDescription] userInfo:nil] raise];
	} else if ([matches count]==0) {
		note = [[self alloc] initWithServerInfo:noteDictionary sender:sender receivers:receivers media:media className:[self className] inManagedObjectContext:context];
	} else {
		note = [matches lastObject];
	}
	
	return note;
}

#pragma mark - Private APIs

/**
 Parse and save the server Note info-dictionary and handle the relationship to Contact and Multimedia.
 @param className
 Because the instance object class description may changed, pass from class method to identify entity name
 */
- (instancetype)initWithServerInfo:(NSDictionary *)noteDictionary
							sender:(Contact *)sender
						 receivers:(NSArray *)receivers
							 media:(NSOrderedSet *)media
						 className:(NSString *)className
			inManagedObjectContext:(NSManagedObjectContext *)context
{
	// Insert self into data base
	self = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:context];
	
	// Deal with properties
	self.uid = noteDictionary[ServerNoteUID];
	self.title = noteDictionary[ServerNoteTitle];
	self.location = noteDictionary[ServerNoteLocation];
	
	self.dueTime = noteDictionary[ServerNoteDueTime];
	self.createTime = noteDictionary[ServerNoteCreateTime];
	
	self.archived = noteDictionary[ServerNoteArchive];
	self.read = noteDictionary[ServerNoteRead];
	self.accepted = noteDictionary[ServerNoteAccepted];
	
	// Deal with relationships: Contact & Multimedia
	self.sender = sender;
	[self addRecievers:[NSSet setWithArray:receivers]];
	[self addMedia:media];
	
	return self;
}

@end

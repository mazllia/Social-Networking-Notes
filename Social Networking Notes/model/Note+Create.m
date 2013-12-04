//
//  Note+Create.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/1.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "Note+Create.h"

#import "Multimedia.h"
#import "NSObject+ClassName.h"

#import "ServerCommunicator.h"	// For parsing dictionary purpose

@implementation Note (Create)

+ (instancetype)noteWithServerInfo:(NSDictionary *)noteDictionary
							sender:(Contact *)sender
						 receivers:(NSArray *)receivers
							 media:(NSArray *)media
			inManagedObjectContext:(NSManagedObjectContext *)context
{
	id note;
	
	/*
	 Perform fetch from core data
	 */
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self className]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uid = %@", noteDictionary[ServerNoteUID]]];
	
	NSError *err;
	NSArray *matches = [context executeFetchRequest:fetchRequest error:&err];
	
	/*
	 Check if fetch result valid & perform actions
	 1. Invalid result
	 2. 0 match: not existed in data base, create
		* Foolproof for paramter: noteDictionary[ServerNoteUID]
	 3. 1 match: query only
	 4. 1 match: modification
		*  Foolproof for parameters: sender & receivers
	 */
	if (!matches || [matches count]>1) {
		[[NSException exceptionWithName:@"Note(Create) Fetch Error" reason:[err localizedDescription] userInfo:nil] raise];
	} else if ([matches count]==0 && noteDictionary[ServerNoteUID]) {
		note = [[NSEntityDescription insertNewObjectForEntityForName:[self className] inManagedObjectContext:context]
				initWithServerInfo:noteDictionary sender:sender receivers:receivers media:media];
	} else if ([noteDictionary count]==1) {
		note = [matches lastObject];
	} else if (sender && receivers) {
		note = [[matches lastObject] initWithServerInfo:noteDictionary sender:sender receivers:receivers media:media];
	}
	
	return note;
}

- (BOOL)allSynced
{
	BOOL mediaSynced = YES;
	for (Multimedia *media in self.media) {
		if (![media.synced boolValue])
			mediaSynced = NO;
	}
	
	return [self.synced boolValue] && mediaSynced;
}

/*
 Future support these properties for individual receivers
 */
- (instancetype)updateStatusWithServerInfo:(NSDictionary *)noteDictionary
								 receivers:(NSArray *)receivers
{
	BOOL read = YES;
	BOOL accepted = YES;
	for (NSDictionary *aReceiver in noteDictionary[ServerNoteReceiverList]) {
		read = read && [aReceiver[ServerNoteRead] boolValue];
		accepted = accepted && [aReceiver[ServerNoteAccepted] boolValue];
	}
	self.read = [NSNumber numberWithBool:read];
	self.accepted = [NSNumber numberWithBool:accepted];
	return self;
}

#pragma mark - Private APIs

/**
 Parse the server info-dictionary and handle the relationship to Contact and Multimedia.
 */
- (instancetype)initWithServerInfo:(NSDictionary *)noteDictionary
							sender:(Contact *)sender
						 receivers:(NSArray *)receivers
							 media:(NSArray *)media
{
	/*
	 1. If info from server is old, then we only need to update Note's relational attributes
	 2. Update all information from server otherwise.
	 */
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSDate *serverInfoDate = [dateFormatter dateFromString:noteDictionary[ServerNoteDueTime]];
	
	// 1
	if ([serverInfoDate earlierDate:self.createTime]==self.createTime) {
		return [self updateStatusWithServerInfo:noteDictionary receivers:receivers];
	}
	
	// 2: Deal with properties
	self.uid = noteDictionary[ServerNoteUID];
	self.title = noteDictionary[ServerNoteTitle]? noteDictionary[ServerNoteTitle]: self.title;
	self.location = noteDictionary[ServerNoteLocation]? noteDictionary[ServerNoteLocation]: self.location;
	
	self.dueTime = noteDictionary[ServerNoteDueTime]? [dateFormatter dateFromString:noteDictionary[ServerNoteDueTime]]: self.dueTime;
	self.createTime = noteDictionary[ServerNoteCreateTime]? [dateFormatter dateFromString:noteDictionary[ServerNoteCreateTime]]: self.createTime;
	
	self.archived = noteDictionary[ServerNoteArchive]? noteDictionary[ServerNoteArchive]: self.archived;
	
	self.synced = @YES;
	
	// 2: Deal with status
	self = [self updateStatusWithServerInfo:noteDictionary receivers:receivers];
	
	// 2: Deal with relationships: Contact & Multimedia
	self.sender = sender;
	self.receivers = [NSSet setWithArray:receivers];
	
	self.media = [NSOrderedSet orderedSetWithArray:media];
	
	return self;
}

@end

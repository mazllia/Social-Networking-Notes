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
	 Perform fetch from disk
	 */
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self className]];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uid = %@", noteDictionary[ServerContactUID]]];
	
	NSError *err;
	NSArray *matches = [context executeFetchRequest:fetchRequest error:&err];
	
	/*
	 Check if fetch result valid & perform actions
	 1. Invalid
	 2. Invalid only if this Note is newly created and not yet synced with server
	 3. Not existed in data base
	 4. Valid
	 */
	if (!matches) {
		[[NSException exceptionWithName:@"Note(Create) Fetch Error" reason:[err localizedDescription] userInfo:nil] raise];
	} else if ([matches count]>1 && noteDictionary[ServerNoteUID]) {
		[[NSException exceptionWithName:@"Note(Create) Fetch Error" reason:@"Multiple Notes with same uid" userInfo:nil] raise];
	} else if ([matches count]==0) {
		note = [[self alloc] initWithServerInfo:noteDictionary sender:sender receivers:receivers media:media className:[self className] inManagedObjectContext:context];
	} else {
		note = [matches lastObject];
	}
	
	return note;
}

- (BOOL)allSynced
{
	BOOL mediaSynced = YES;
	for (Multimedia *media in self.media) {
		if (!media.synced)
			mediaSynced = NO;
	}
	
	return self.synced && mediaSynced;
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
							 media:(NSArray *)media
						 className:(NSString *)className
			inManagedObjectContext:(NSManagedObjectContext *)context
{
	// Insert self into data base
	self = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:context];
	
	// Deal with properties
	self.uid = noteDictionary[ServerNoteUID];
	self.title = noteDictionary[ServerNoteTitle];
	self.location = noteDictionary[ServerNoteLocation];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	self.dueTime =  [dateFormatter dateFromString:noteDictionary[ServerNoteDueTime]];
	self.createTime = [dateFormatter dateFromString:noteDictionary[ServerNoteCreateTime]];
	
	self.archived = [NSNumber numberWithBool:(BOOL)noteDictionary[ServerNoteArchive]];;
	
	// Future support these properties for individual receivers
	for (NSDictionary *aReceiver in noteDictionary[ServerNoteReceiverList]) {
		self.read = [NSNumber numberWithBool:[self.read boolValue] & (BOOL)aReceiver[ServerNoteRead]];
		self.accepted = [NSNumber numberWithBool:[self.accepted boolValue] & (BOOL)aReceiver[ServerNoteAccepted]];
	}
	
	// Deal with relationships: Contact & Multimedia
	self.sender = sender;
	[self addReceivers:[NSSet setWithArray:receivers]];
	
	for (Multimedia *insertMultimedia in media) {
		[insertMultimedia addWhichNotesIncludeObject:self];
		/// @bug why cannot use addMedia?
//		[self addMediaObject:insertMultimedia];
	}
//	[self addMedia:[NSOrderedSet orderedSetWithArray:media]];
	
	return self;
}

@end

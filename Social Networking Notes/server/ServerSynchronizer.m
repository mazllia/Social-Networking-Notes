//
//  ServerSynchronizer.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 2013/11/16.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "ServerSynchronizer.h"
#import "ServerCommunicator.h"
#import "DatabaseManagedDocument.h"
#import "FBCommunicator.h"

#import "Note+Create.h"
#import "Contact+Create.h"

@interface ServerSynchronizer () <ServerCommunicatorDelegate>

@property (nonatomic) BOOL syncingNotes;
@property (nonatomic) BOOL syncingContacts;

// Override readonly
@property (nonatomic, strong, readonly) ServerCommunicator *communicator;
@property (nonatomic, strong) NSOperationQueue *syncQueue;
@property (nonatomic, strong) NSTimer *autoSyncTimer;

@property (nonatomic, strong) NSManagedObjectContext *dataContext;

@property (nonatomic, strong) NSArray *notesNeedSync;
@property (nonatomic, strong) NSArray *contactsNeedSync;

@end

@implementation ServerSynchronizer
static id sharedServerSynchronizer = nil;

- (id)init
{
	self = [super init];
	if (self) {
		// Set up properties
		_autoSyncTimeInterval = 300.0;
		_autoSyncTimer = [NSTimer scheduledTimerWithTimeInterval:_autoSyncTimeInterval target:self selector:@selector(sync) userInfo:nil repeats:YES];
		[_autoSyncTimer setTolerance:_autoSyncTimeInterval*0.1];
		
		_communicator = [[ServerCommunicator alloc] initWithDelegate:self];
		_syncQueue = [[NSOperationQueue alloc] init];
		
		_dataContext = [DatabaseManagedDocument sharedDatabase].managedObjectContext;
	}
	return self;
}

#pragma mark - Public APIs

- (void)sync
{
	// If it is syncing under operation, ignore the sync operation for this time
	if (!self.syncing) {
		// Configure: pull then push
		NSBlockOperation *pullOperation = [[NSBlockOperation alloc] init];
		
		[pullOperation addExecutionBlock:^{
			[self.communicator getLastestNotes];
		}];
		[pullOperation addExecutionBlock:^{
			[self.communicator getAvailableUsersFromFBFriends:[self getFBFriendsUID]];
		}];
		
		NSBlockOperation *pushOperation = [NSBlockOperation blockOperationWithBlock:^{
			[self.communicator pushNotes:self.notesNeedSync contacts:self.contactsNeedSync];
		}];
		[pushOperation addDependency:pullOperation];
		
		// Start to sync
		self.syncingContacts = YES;
		self.syncingNotes = YES;
		[self.syncQueue addOperations:@[pullOperation, pushOperation] waitUntilFinished:NO];
	}
}

- (BOOL)isSyncing
{
	return self.syncingContacts || self.syncingNotes;
}

- (void)setAutoSyncTimeInterval:(NSTimeInterval)autoSyncTimeInterval
{
	if (autoSyncTimeInterval > 0) {
		_autoSyncTimeInterval = autoSyncTimeInterval;
		// Update autoSyncTimer with new time interval
		self.autoSyncTimer = [NSTimer scheduledTimerWithTimeInterval:_autoSyncTimeInterval target:self selector:@selector(sync) userInfo:nil repeats:YES];
		[self.autoSyncTimer setTolerance:_autoSyncTimeInterval*0.1];
	}
}

#pragma mark - Private APIs

- (NSArray *)notesNeedSync
{
	if (!_notesNeedSync) {
		NSFetchRequest *query = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
		[query setPredicate:[NSPredicate predicateWithBlock:^BOOL(Note *evaluatedObject, NSDictionary *bindings) {
			return ![evaluatedObject allSynced];
		}]];
		
		NSError *err;
		_notesNeedSync = [self.dataContext executeFetchRequest:query error:&err];
		
		if (err) {
			[[NSException exceptionWithName:@"ServerSynchronizer Note fetch error" reason:err.localizedDescription userInfo:nil] raise];
		}
	}
	return _notesNeedSync;
}

- (NSArray *)contactsNeedSync
{
	if (_contactsNeedSync) {
		NSFetchRequest *query = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
		[query setPredicate:[NSPredicate predicateWithFormat:@"synced = YES"]];
		
		NSError *err;
		_contactsNeedSync = [self.dataContext executeFetchRequest:query error:&err];
		
		if (err) {
			[[NSException exceptionWithName:@"ServerSynchronizer Contact fetch error" reason:err.localizedDescription userInfo:nil] raise];
		}
	}
	return _contactsNeedSync;
}

#pragma mark - Server Communicator Delegate

- (void)serverCommunicatorContactSynced:(NSArray *)syncedContactDictionaries fromAction:(ServerAction)action
{
	switch (action) {
		case ServerActionPull:
			// After pulling, local.contact.sync==NO means local contact is newer than server
			for (NSDictionary *contactDictionary in syncedContactDictionaries) {
				Contact *newContact = [Contact contactWithServerInfo:contactDictionary inManagedObjectContext:managedObjectContext];
			}
			break;
			
		case ServerActionPush:
			
			break;
			
		default:
			[[NSException exceptionWithName:@"ServerCommunicatorDelegate" reason:@"Contact unknown ServerAction type" userInfo:nil] raise];
			break;
	}
	self.syncingContacts = NO;
	self.contactsNeedSync = nil;
}

- (void)serverCommunicatorNotesSynced:(NSArray *)syncedNoteDictionaries fromAction:(ServerAction)action
{
	// After pulling, local.contact.sync==NO means local contact is newer than server
}

#pragma mark - singleton

+ (instancetype)sharedSynchronizer
{
	if (!sharedServerSynchronizer) {
		sharedServerSynchronizer = [[super allocWithZone:nil] init];
	}
	return sharedServerSynchronizer;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
	return [self sharedSynchronizer];
}

@end

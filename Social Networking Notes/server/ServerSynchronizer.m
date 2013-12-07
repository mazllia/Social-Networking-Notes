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

#import "Note+Create.h"
#import "Contact+Create.h"
#import "Multimedia+Create.h"

#define serverRootURL @"http://people.cs.nctu.edu.tw/~chiangcw/"
#define createAcountURL @"create_account.php"

@interface ServerSynchronizer () <ServerCommunicatorDelegate>

@property (nonatomic) BOOL syncingNotes;
@property (nonatomic) BOOL syncingContacts;

// Override readonly
@property (readwrite) Contact *currentUser;
@property (readwrite) NSMutableArray *notesWithoutUID;

@property (nonatomic, strong) NSOperationQueue *syncQueue;
@property (nonatomic, strong) NSTimer *autoSyncTimer;

@property (nonatomic, strong, readonly) ServerCommunicator *communicator;
@property (nonatomic, strong) NSManagedObjectContext *dataContext;

@property (nonatomic, strong) NSArray *notesNeedSync;
@property (nonatomic, strong) NSArray *contactsNeedSync;

@end

@implementation ServerSynchronizer
static id sharedServerSynchronizer = nil;

- (id)initWithFBGraphUser:(id <FBGraphUser>)user
{
	self = [super init];
	if (self) {
		// Set up properties
		_autoSyncTimeInterval = 300.0;
		_autoSyncTimer = [NSTimer scheduledTimerWithTimeInterval:_autoSyncTimeInterval target:self selector:@selector(sync) userInfo:nil repeats:YES];
		[_autoSyncTimer setTolerance:_autoSyncTimeInterval*0.1];
		
		_dataContext = [DatabaseManagedDocument sharedDatabase].managedObjectContext;

		// Init currentUser
		NSString *uid = [self registerUserAccount:user[@"id"]];
 		_currentUser = [Contact contactWithServerInfo:@{ServerContactUID: uid, ServerContactFbAccountIdentifier: user[@"id"], ServerContactFBAccountName: user.name}
							   inManagedObjectContext:_dataContext];
		
		_communicator = [[ServerCommunicator alloc] initWithDelegate:self withUserContact:_currentUser];
		_syncQueue = [[NSOperationQueue alloc] init];
		
	}
	return self;
}

- (void)dealloc
{
	// Archive the notesWithoutUID
	if (![NSKeyedArchiver archiveRootObject:self.notesWithoutUID toFile:[self notesWithoutUIDArchivePath]]) {
		[[NSException exceptionWithName:@"ServerSynchronizer archive error" reason:[self notesWithoutUIDArchivePath] userInfo:nil] raise];
	}
}

#pragma mark - Public APIs

- (void)sync
{
	// If it is syncing under operation, ignore the sync operation for this time
	NSLog(@"Sync status: %i", self.syncing);
	if (!self.syncing) {
		// Configure: pull then push
		NSBlockOperation *pullOperation = [[NSBlockOperation alloc] init];
		
		[pullOperation addExecutionBlock:^{
			NSLog(@"GetLatestNotes Now");
			[self.communicator getLastestNotes];
		}];
		[pullOperation addExecutionBlock:^{
			NSLog(@"GetAvailalbleFriends Now");
			[self.communicator getAvailableUsersFromFBFriends];
		}];
		
		NSBlockOperation *pushOperation = [NSBlockOperation blockOperationWithBlock:^{
			[self.communicator pushNotes:self.notesNeedSync contacts:self.contactsNeedSync];
		}];
		[pushOperation addDependency:pullOperation];
		
		// Start to sync
		self.syncingContacts = YES;
		self.syncingNotes = YES;
		NSLog(@"Start to sync (execute operation queue)");
		[self.syncQueue addOperations:@[pullOperation, pushOperation] waitUntilFinished:NO];
	}
}

- (BOOL)syncing
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

- (NSMutableArray *)notesWithoutUID
{
	if (!_notesWithoutUID) {
		_notesWithoutUID = [NSKeyedUnarchiver unarchiveObjectWithFile:[self notesWithoutUIDArchivePath]];
	}
	return _notesWithoutUID;
}

#pragma mark - Private APIs

- (NSString *)registerUserAccount:(NSString *)facebookUID
{
	NSString *deviceUID = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",serverRootURL,createAcountURL]];
	NSString *httpBodyString = [NSString stringWithFormat:@"facebook_uid=%@&deviceUID=%@",facebookUID, deviceUID];
    
    NSData *responseData =[self httpPostConnect:url httpBodyString:httpBodyString];
	NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
	if (!jsonData)
		[[NSException exceptionWithName:@"Server Synchronizer" reason:@"Register user account mySQL failed!" userInfo:nil] raise];
	
	return jsonData[ServerNoteUserUID];
}

- (NSData *)httpPostConnect:(NSURL *)url httpBodyString:(NSString *)httpBodyString
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval: 10.0]; // Will timeout after 2 seconds
    
    [request setHTTPBody:[httpBodyString dataUsingEncoding:NSUTF8StringEncoding]];
	
    NSError* error;
    NSData *data =[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error)
		[[NSException exceptionWithName:@"Server Synchronizer" reason:error.localizedDescription userInfo:nil] raise];
    else
        return data;
}

- (NSString *)notesWithoutUIDArchivePath
{
	NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	url = [url URLByAppendingPathComponent:@"Default Database" isDirectory:YES];
	url = [url URLByAppendingPathComponent:@"notesWithoutUID.archive"];
	return [url path];
}

- (NSArray *)notesNeedSync
{
	if (!_notesNeedSync) {
		[self.dataContext performBlockAndWait:^{
			NSFetchRequest *query = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
			
			NSError *err;
			NSMutableArray *resultNotes = [NSMutableArray array];
			for (Note* aNote in [self.dataContext executeFetchRequest:query error:&err]) {
				if (![aNote allSynced]) {
					[resultNotes addObject:aNote];
				}
			}
			
			if (err) {
				[[NSException exceptionWithName:@"ServerSynchronizer Note fetch error" reason:err.localizedDescription userInfo:nil] raise];
			}
			
			[resultNotes addObjectsFromArray:self.notesWithoutUID];
			_notesNeedSync = [resultNotes copy];
		}];
	}
	return _notesNeedSync;
}

- (NSArray *)contactsNeedSync
{
	if (!_contactsNeedSync) {
		[self.dataContext performBlockAndWait:^{
			NSFetchRequest *query = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
			[query setPredicate:[NSPredicate predicateWithFormat:@"synced = 0"]];
			
			NSError *err;
			NSArray *resultContacts = [self.dataContext executeFetchRequest:query error:&err];
			
			if (err) {
				[[NSException exceptionWithName:@"ServerSynchronizer Contact fetch error" reason:err.localizedDescription userInfo:nil] raise];
			}
			
			_contactsNeedSync = resultContacts;
		}];
	}
	return _contactsNeedSync;
}

- (void)insertNotesAndHandleRelationship:(NSArray *)noteArray
{
	NSManagedObjectContext *managedObjectContext = self.dataContext;
	[managedObjectContext performBlockAndWait:^{
		for (NSDictionary *noteDictionary in noteArray) {
			// Handle sender
			Contact *sender = [Contact contactWithServerInfo:@{ServerContactUID: noteDictionary[ServerNoteSenderUID]} inManagedObjectContext:managedObjectContext];
			
			// Handle receivers
			NSMutableArray *receivers = [NSMutableArray arrayWithCapacity:[(NSArray *)noteDictionary[ServerNoteReceiverList] count]];
			for (NSDictionary *receiverInfo in noteDictionary[ServerNoteReceiverList]) {
				Contact *receiver = [Contact contactWithServerInfo:@{ServerContactUID: receiverInfo[ServerNoteReceiverUID]} inManagedObjectContext:managedObjectContext];
				[receivers addObject:receiver];
			}
			
			// Handle multimedia
			NSMutableArray *multimedia = [NSMutableArray arrayWithCapacity:[(NSArray *)noteDictionary[ServerMediaFileList] count]];
			for (NSDictionary *multimediaInfo in noteDictionary[ServerMediaFileList]) {
				Multimedia *multimedium = [Multimedia multimediaWithServerInfo:multimediaInfo data:nil inManagedObjectContext:managedObjectContext];
				[multimedia addObject:multimedium];
			}

			Note *newNote = [Note noteWithServerInfo:noteDictionary sender:sender receivers:receivers media:multimedia inManagedObjectContext:managedObjectContext];
		}
	}];
}

#pragma mark - Server Communicator Delegate
/*
 Common action
 ===
 We need to do the following:
 
 - Compare **item.uid** then update attribute or create new item with *Create categories
 - Change the **item.snyced** to *YES*
 
 **Handled by Create categories**
 
 Pull action
 ===
 Local item.synced is *NO* means local items is newer than server.
 
 ### Contacts
 Consider server info are old, ignore them.
 
 ### Notes
 We only need to update Note's relational attributes as follow:
 
 - accepted
 - read
 
 **Handled by Note(Create)**
 
 Push action
 ===
 Newly created **note.uid** is *nil*, then we need to compare the **note.createTime** to match newly created note. (controller block user's modification if ServerSynchronizer is now syncing; otherwise, createTime changes and this comparison is invalid)
 */

- (void)serverCommunicatorContactSynced:(NSArray *)syncedContactDictionaries fromAction:(ServerAction)action
{
	NSLog(@"%lu contact synced", (unsigned long)[syncedContactDictionaries count]);
	NSManagedObjectContext *managedObjectContext = self.dataContext;
	[managedObjectContext performBlockAndWait:^{
		switch (action) {
			case ServerActionPull:
				for (NSDictionary *serverContactInfo in syncedContactDictionaries) {
					// Query only, the default value of Contact.synced is YES
					Contact *aContact = [Contact contactWithServerInfo:@{ServerContactUID: serverContactInfo[ServerContactUID]} inManagedObjectContext:managedObjectContext];
					// Contact.synced==YES means 1. Newly created contact 2. Existed contact with old info
					if ([aContact.synced boolValue]) {
						// Modify them
						[Contact contactWithServerInfo:serverContactInfo inManagedObjectContext:managedObjectContext];
						aContact.synced = [NSNumber numberWithBool:YES];
					}
					// Ignore otherwise
				}
				break;
				
			case ServerActionPush:
				for (NSDictionary *serverContactInfo in syncedContactDictionaries) {
					Contact *aContact = [Contact contactWithServerInfo:serverContactInfo inManagedObjectContext:managedObjectContext];
					aContact.synced = [NSNumber numberWithBool:YES];
				}
				break;
				
			default:
				[[NSException exceptionWithName:@"ServerCommunicatorDelegate" reason:@"Contact unknown ServerAction type" userInfo:nil] raise];
				break;
		}
	}];
	if (action==ServerActionPush) {
		NSLog(@"finishContactSnyc");
		self.syncingContacts = NO;
		self.contactsNeedSync = nil;
	}
}

- (void)serverCommunicatorNotesSynced:(NSArray *)syncedNoteDictionaries fromAction:(ServerAction)action
{
	NSLog(@"%lu notes synced", (unsigned long)[syncedNoteDictionaries count]);
	switch (action) {
			/*
			 1. Find related note in notesWithoutUID
			 2. Match by createTime
			 2.1 Match: Delete notesWithoutUID and insert into DB with synced=YES
			 2.2 NO: insert into DB with synced=YES
			 */
		case ServerActionPush:
			for (NSDictionary *serverNoteInfo in syncedNoteDictionaries) {
				NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
				[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
				// 1
				[self.notesWithoutUID enumerateObjectsUsingBlock:^(Note *aNoteWithoutUID, NSUInteger idx, BOOL *stop) {
					NSDate *serverNoteDate = [dateFormatter dateFromString:serverNoteInfo[ServerNoteCreateTime]];
					// 2
					if ([aNoteWithoutUID.createTime isEqualToDate:serverNoteDate]) {
						// 2.1
						[self.notesWithoutUID removeObjectAtIndex:idx];
					}
				}];
			}
			break;
			
			/*
			 Insert into DB with synced=YES
			 */
		case ServerActionPull:
			break;
			
		default:
			[[NSException exceptionWithName:@"ServerCommunicatorDelegate" reason:@"Note unknown ServerAction type" userInfo:nil] raise];
			break;
		
	}
	
	[self insertNotesAndHandleRelationship:syncedNoteDictionaries];
	
	if (action==ServerActionPush) {
		NSLog(@"finishNoteSnyc");
		self.syncingNotes = NO;
		self.notesNeedSync = nil;
	}

}

#pragma mark - singleton

+ (instancetype)sharedSynchronizer
{
	if (!sharedServerSynchronizer) {
		[[NSException exceptionWithName:@"Server Synchronizer" reason:@"Did not initilize synchronizer before first use" userInfo:nil] raise];
	}
	return sharedServerSynchronizer;
}

+ (instancetype)syncronizerInitWithFBGraphUser:(id<FBGraphUser>)user
{
	if (!sharedServerSynchronizer) {
		sharedServerSynchronizer = [[super allocWithZone:nil] initWithFBGraphUser:user];
	}
	return sharedServerSynchronizer;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
	return [self sharedSynchronizer];
}

+ (void)closeSynchornizer
{
	sharedServerSynchronizer = nil;
}

@end

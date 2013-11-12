//
//  DatabaseManagedDocument.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/9/16.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "DatabaseManagedDocument.h"
//#import "ServerCommunicator.h"

@implementation DatabaseManagedDocument
static DatabaseManagedDocument *sharedDatabaseManagedDocument = nil;

- (void)getDatabaseReadyFromDisk
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:[self.fileURL path]]) {
		// does not exist on disk, so create it
		[self saveToURL:self.fileURL
	   forSaveOperation:UIDocumentSaveForCreating
	  completionHandler:^(BOOL success) {
		  if (!success) {
			  NSLog(@"Error creating managed document");
			  return;
		  }
//		  [self fetchFromServer];
	  }];
	} else if (self.documentState == UIDocumentStateClosed) {
		// exists on disk, but we need to open it
		[self openWithCompletionHandler:^(BOOL success) {
			if (!success) {
				NSLog(@"Error creating managed document");
				return;
			}
//			[self fetchFromServer];
		}];
	} else if (self.documentState == UIDocumentStateNormal) {
		// already open and ready to use
//		[self fetchFromServer];
	}
}

#pragma mark - Server

//- (void)fetchFromServer
//{
//	ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
//	// 1. If notes not sync, then push
//	// 2. Get new notes
//	[serverCommunicator pullNotesWith:<#(NSString *)#>]
//}

#pragma mark - Singleton

+ (instancetype)sharedDatabase
{
	if (!sharedDatabaseManagedDocument) {
		sharedDatabaseManagedDocument = [[super allocWithZone:NULL] init];
		
		NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
		[url URLByAppendingPathComponent:@"Default Database"];
		sharedDatabaseManagedDocument = [[self alloc] initWithFileURL:url];
		
		[sharedDatabaseManagedDocument getDatabaseReadyFromDisk];
//		[sharedDatabaseManagedDocument fetchFromServer];
	}
	return sharedDatabaseManagedDocument;
}

+ (instancetype)allocWithZone:(NSZone *)zone
{
	return [self sharedDatabase];
}



@end

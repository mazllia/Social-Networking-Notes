//
//  DatabaseManagedDocument.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/9/16.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "DatabaseManagedDocument.h"

@implementation DatabaseManagedDocument
static DatabaseManagedDocument *sharedDatabaseManagedDocument = nil;

- (id)initWithFileURL:(NSURL *)url
{
	self = [super initWithFileURL:url];
	if (self) {
		[self getDatabaseReadyFromDisk];
	}
	return self;
}

#pragma mark - Private APIs

- (void)getDatabaseReadyFromDisk
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:[self.fileURL path]]) {
		// does not exist on disk, so create it
		[self saveToURL:self.fileURL
	   forSaveOperation:UIDocumentSaveForCreating
	  completionHandler:^(BOOL success) {
		  if (!success)
			  [[NSException exceptionWithName:@"Database Managed Document" reason:@"Error creating managed document" userInfo:nil] raise];
	  }];
	} else if (self.documentState == UIDocumentStateClosed) {
		// exists on disk, but we need to open it
		[self openWithCompletionHandler:^(BOOL success) {
			if (!success)
				[[NSException exceptionWithName:@"Database Managed Document" reason:@"Error creating managed document" userInfo:nil] raise];
		}];
	} else if (self.documentState == UIDocumentStateNormal) {
		// already open and ready to use
	}
}

#pragma mark - Singleton

+ (instancetype)sharedDatabase
{
	if (!sharedDatabaseManagedDocument) {
		NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
		url = [url URLByAppendingPathComponent:@"Default Database"];
		sharedDatabaseManagedDocument = [[super allocWithZone:NULL] initWithFileURL:url];
	}
	return sharedDatabaseManagedDocument;
}

+ (instancetype)allocWithZone:(NSZone *)zone
{
	return [self sharedDatabase];
}

@end

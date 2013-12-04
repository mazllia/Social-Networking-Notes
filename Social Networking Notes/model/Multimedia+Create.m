//
//  Multimedia+Create.m
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/20.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "Multimedia+Create.h"
#import "NSObject+ClassName.h"

#import "ServerCommunicator.h"	// For parsing dictionary purpose

@implementation Multimedia (Create)

+ (instancetype)multimediaWithServerInfo:(NSDictionary *)multimediaDictionary
									data:(NSData *)data
				  inManagedObjectContext:(NSManagedObjectContext *)context
{
	id multimedia;
	
	/*
	 Perform fetch from disk
	 */
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self className]];
	[fetchRequest setPredicate: [NSPredicate predicateWithFormat:@"fileName = %@", multimediaDictionary[ServerMediaFileName]]];
	
	NSError *err;
	NSArray *matches = [context executeFetchRequest:fetchRequest error:&err];
	
	/*
	 Check if fetch result valid & perform actions
	 1. Invalid result
	 2. 0 match: not existed in data base, create
		 * Foolproof for paramter: multimediaDictionary[ServerMediaFileName]
	 3. 1 match: query only
	 4. 1 match: modification
	 */
	if (!matches || [matches count]>1) {
		[[NSException exceptionWithName:@"Multimedia(Create) Fetch Error" reason:[err localizedDescription] userInfo:nil] raise];
	} else if ([matches count]==0 && multimediaDictionary[ServerMediaFileName]) {
		multimedia = [[NSEntityDescription insertNewObjectForEntityForName:[self className] inManagedObjectContext:context]
					  initWithServerInfo:multimediaDictionary data:data];
	} else if ([multimediaDictionary count]==1) {
		multimedia = [matches lastObject];
	} else {
		multimedia = [[matches lastObject] initWithServerInfo:multimediaDictionary data:data];
	}
	
	return multimedia;
}

- (NSData *)data
{
	return [[NSFileManager defaultManager] contentsAtPath:[self localURL]];
}

- (NSString *)localURL
{
	NSError *err;
	NSString *documentURL = [[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&err] path];
	if (err) {
		[[NSException exceptionWithName:@"Multimedia(Create) localURL Directory" reason:[err localizedDescription] userInfo:nil] raise];
	}
	return [documentURL stringByAppendingPathComponent:self.fileName];
}

#pragma mark - Private APIs

/**
 Parse the server info-dictionary (the relationship will be handle in Note+Create).
 */
- (instancetype)initWithServerInfo:(NSDictionary *)multimediaDictionary
							  data:(NSData *)data
{
	// Deal with properties
	self.fileName = multimediaDictionary[ServerMediaFileName];
	self.synced = multimediaDictionary[ServerMediaSync]? multimediaDictionary[ServerMediaSync]: self.synced;
	
	// Save the data file
	[data writeToURL:[NSURL URLWithString:[self localURL]] atomically:YES];
	
	return self;
}

@end

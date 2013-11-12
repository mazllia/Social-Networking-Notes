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
	 1. Invalid
	 2. Not existed in data base
	 3. Valid
	 */
	if (!matches || [matches count]>1) {
		[[NSException exceptionWithName:@"Multimedia(Create) Fetch Error" reason:[err localizedDescription] userInfo:nil] raise];
	} else if ([matches count]==0) {
		multimedia = [[self alloc] initWithServerInfo:multimediaDictionary data:data className:[self className] inManagedObjectContext:context];
	} else {
		multimedia = [matches lastObject];
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
	NSString *documentURL = [[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&err] absoluteString];
	if (err) {
		[[NSException exceptionWithName:@"Multimedia(Create) localURL Directory" reason:[err localizedDescription] userInfo:nil] raise];
	}
	return [documentURL stringByAppendingPathComponent:self.fileName];
}

#pragma mark - Private APIs

/**
 Parse and save the server info-dictionary (the relationship will be handle in Note+Create).
 @param className
 Because the instance object class description may changed, pass from class method to identify entity name
 */
- (instancetype)initWithServerInfo:(NSDictionary *)multimediaDictionary
							  data:(NSData *)data
						 className:(NSString *)className
			inManagedObjectContext:(NSManagedObjectContext *)context
{
	// Insert self into data base
	self = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:context];
	
	// Deal with properties
	self.fileName = multimediaDictionary[ServerMediaFileName];
	
	// Save the data file
	[data writeToURL:[self localURL] atomically:YES];
	
	return self;
}

@end

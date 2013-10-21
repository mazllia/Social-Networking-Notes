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
	NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Multimedia *evaluatedObject, NSDictionary *bindings) {
		return [[evaluatedObject.localUrl lastPathComponent] isEqualToString:multimediaDictionary[ServerMediaFileName]];
	}];
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self className]];
	[fetchRequest setPredicate: predicate];
	
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
	return [[NSFileManager defaultManager] contentsAtPath:self.localUrl];
}

- (NSString *)fileName
{
	return [self.localUrl lastPathComponent];
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
	
	// Get the account id and generate the cloudURL
	self.cloudUrl = ;
	
	// Get the account id and save to /Documents/<#account>/ as cloudURL did
	NSString *localSearchPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, NO) firstObject] stringByAppendingPathComponent:<#(NSString *)#>;
	self.localUrl = [[NSFileManager defaultManager] createFileAtPath: contents:data attributes:nil];
}

@end

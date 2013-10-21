//
//  Contact+Create.h
//  Social Networking Notes
//
//  Created by 戴鵬洋 on 13/10/9.
//  Copyright (c) 2013年 Dai Peng-Yang. All rights reserved.
//

#import "Contact.h"

@interface Contact (Create)

/**
 This method queries or creates (save to database) a Contact to you with provided server info. The relationships of Contact will be managed by @em Note(Creation). @see ServerCommunicatior.h
 @param contactDictionary
 Please use the @e ServerCommunicator.h defined key in @e NSDictionary. This dictionary should at least contain @b ServerContactUID to perform query; if create is needed, you need to provide furthur information.
 @param context
 Specify in which @e NSManagedObjectContext should be saved.
 @return Returns a new or queried Contact
 */

+ (instancetype)contactWithServerInfo:(NSDictionary *)contactDictionary
			   inManagedObjectContext:(NSManagedObjectContext *)context;

@end
